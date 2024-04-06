// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "../interface/IGroFiStakingManager.sol";
import "../interface/IVault.sol";
import ".././interface/ILoanNFTDescriptor.sol";

///MSG CODE
///E1: Package not found
///E2: Amount invalid
///E3: You are not owner
///E4: Time invalid

contract TreasuryBorrow is AccessControl, ERC721Upgradeable {
  address public stakingManager;
  address public vault;
  address public nftDes;
  uint256 public currentTokenId;

  mapping(uint256 => BorrowInfo) public borrowInfo;
  mapping(uint256 => PackageInfo) public packageInfo;

  bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");

  function initialize(address _stakingManager, address _vault, address _nftDes) public initializer {
    __ERC721_init("GroFi_Loans_NFT", "GROFI_LOANS_NFT");
    stakingManager = _stakingManager;
    vault = _vault;
    nftDes = _nftDes;
    _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    _grantRole(OPERATOR_ROLE, msg.sender);
  }

  function updateConfig(address _stakingManager, address _vault) public onlyRole(OPERATOR_ROLE) {
    stakingManager = _stakingManager;
    vault = _vault;
  }

  function updateNFT(address _nftDes) public onlyRole(OPERATOR_ROLE) {
    nftDes = _nftDes;
  }

  function configPackageInfo(PackageInfoParam[] memory packages) public onlyRole(OPERATOR_ROLE) {
    for (uint256 i = 0; i < packages.length; i++) {
      packageInfo[packages[i].packageId] = PackageInfo(packages[i].period, packages[i].maxBorrowRatio, packages[i].annualRate, packages[i].minBorrow);
      emit ConfigPackage(packages[i].packageId, packages[i].period, packages[i].annualRate, packages[i].maxBorrowRatio, packages[i].minBorrow);
    }
  }

  struct PackageInfo {
    uint256 period;
    uint256 maxBorrowRatio;
    uint256 annualRate;
    uint256 minBorrow;
  }

  struct PackageInfoParam {
    uint256 packageId;
    uint256 period;
    uint256 maxBorrowRatio;
    uint256 annualRate;
    uint256 minBorrow;
  }

  struct BorrowInfo {
    uint256 borrowAt;
    uint256 amountBorrow;
    uint256 packageId; 
    uint256 stakeId;
  }

  event Borrow(uint256 indexed tokenId, address indexed from, uint256 indexed amount, uint256 stakeId, uint256 packageId);
  event ConfigPackage(uint256 indexed packageId, uint256 indexed period, uint256 indexed annualRate, uint256 maxBorrowRatio, uint256 minBorrow);
  event ReturnStakingNFT(uint256 indexed tokenId, address indexed from, uint256 stakeId);
  event PayOff(uint256 indexed tokenId, address indexed from, uint256 stakeId, uint256 rewardUser, uint256 rewardVault);
  event Withdraw(uint256 indexed tokenId, address indexed from, uint256 stakeId);

  receive() external payable {}

  function mustReturn(uint256 _tokenId) public view returns(uint256) {
    return borrowInfo[_tokenId].amountBorrow + borrowInfo[_tokenId].amountBorrow * packageInfo[borrowInfo[_tokenId].packageId].annualRate / 100 ether;
  }

  function borrow(
    uint256 _amount,
    uint256 _tokenId,
    uint256 _packageId
  ) public {
    uint256 nftStakeAmount = IGroFiStakingManager(stakingManager).uriInfoById(_tokenId).amount;
    require(packageInfo[_packageId].annualRate != 0, "E1");
    require(_amount <= nftStakeAmount * packageInfo[_packageId].maxBorrowRatio / 100 ether && _amount >= packageInfo[_packageId].minBorrow, "E2");
    IGroFiStakingManager(stakingManager).safeTransferFrom(msg.sender, address(this), _tokenId);
    // Send U2U to user
    IVault(vault).withdraw(_amount);
    currentTokenId ++;
    payable(msg.sender).transfer(_amount);
    _mint(msg.sender, currentTokenId);
    borrowInfo[currentTokenId].borrowAt = block.timestamp;
    borrowInfo[currentTokenId].amountBorrow = _amount;
    borrowInfo[currentTokenId].packageId = _packageId;
    borrowInfo[currentTokenId].stakeId = _tokenId;
    emit Borrow(currentTokenId, msg.sender, _amount, _tokenId, _packageId);
  }

  function returnStakingNFT(uint256 _tokenId) public payable {
    require(ownerOf(_tokenId) == msg.sender, "E3");
    // require(borrowInfo[_tokenId].amountBorrow == msg.value);
    require(borrowInfo[_tokenId].borrowAt + packageInfo[borrowInfo[_tokenId].packageId].period >= block.timestamp, "E4");
    
    require(msg.value >= mustReturn(_tokenId), "E2");
    payable(msg.sender).transfer(msg.value - mustReturn(_tokenId));
    payable(vault).transfer(address(this).balance);
    IGroFiStakingManager(stakingManager).safeTransferFrom(address(this), ownerOf(_tokenId), borrowInfo[_tokenId].stakeId);
    _burn(_tokenId);
    emit ReturnStakingNFT(_tokenId, msg.sender, borrowInfo[_tokenId].stakeId);
  }

  function payOff(uint256 _tokenId) public onlyRole(OPERATOR_ROLE) {
    require(borrowInfo[_tokenId].borrowAt + packageInfo[borrowInfo[_tokenId].packageId].period < block.timestamp, "E4");
    uint256 rewardVault = 0;
    uint256 rewardUser = 0;
    if (IGroFiStakingManager(stakingManager).pendingReward(borrowInfo[_tokenId].stakeId) != 0) {
      IGroFiStakingManager(stakingManager).claimReward(borrowInfo[_tokenId].stakeId);
      uint256 rateBorrowByTotal = borrowInfo[_tokenId].amountBorrow * 1 ether / IGroFiStakingManager(stakingManager).uriInfoById(borrowInfo[_tokenId].stakeId).amount * 100;
      rewardVault = address(this).balance * rateBorrowByTotal / 100 ether * packageInfo[borrowInfo[_tokenId].packageId].annualRate / 100 ether;
      payable(vault).transfer(rewardVault);
      rewardUser = address(this).balance;
      payable(ownerOf(_tokenId)).transfer(rewardUser);
    }
    IGroFiStakingManager(stakingManager).unStake(borrowInfo[_tokenId].stakeId);
    emit PayOff(_tokenId, ownerOf(_tokenId), borrowInfo[_tokenId].stakeId, rewardUser, rewardVault);
  }

  function multiPayOff(uint256[] memory _tokenIds) public onlyRole(OPERATOR_ROLE) {
    for (uint256 i = 0; i < _tokenIds.length; i++) {
      uint256 rewardVault = 0;
      uint256 rewardUser = 0;
      require(borrowInfo[_tokenIds[i]].borrowAt + packageInfo[borrowInfo[_tokenIds[i]].packageId].period < block.timestamp, "E4");
      if (IGroFiStakingManager(stakingManager).pendingReward(borrowInfo[_tokenIds[i]].stakeId) != 0) {
        IGroFiStakingManager(stakingManager).claimReward(borrowInfo[_tokenIds[i]].stakeId);
        uint256 rateBorrowByTotal = borrowInfo[_tokenIds[i]].amountBorrow * 1 ether / IGroFiStakingManager(stakingManager).uriInfoById(borrowInfo[_tokenIds[i]].stakeId).amount * 100;
        rewardVault = address(this).balance * rateBorrowByTotal / 100 ether * packageInfo[borrowInfo[_tokenIds[i]].packageId].annualRate / 100 ether;
        payable(vault).transfer(rewardVault);
        rewardUser = address(this).balance;
        payable(ownerOf(_tokenIds[i])).transfer(rewardUser);
      }
      IGroFiStakingManager(stakingManager).unStake(borrowInfo[_tokenIds[i]].stakeId);
      emit PayOff(_tokenIds[i], ownerOf(_tokenIds[i]), borrowInfo[_tokenIds[i]].stakeId, rewardUser, rewardVault);
    } 
  }

  function withdrawPayOff(uint256 _tokenId) public onlyRole(OPERATOR_ROLE) {
    IGroFiStakingManager(stakingManager).withdraw(borrowInfo[_tokenId].stakeId);
    payable(vault).transfer(borrowInfo[_tokenId].amountBorrow + borrowInfo[_tokenId].amountBorrow * packageInfo[borrowInfo[_tokenId].packageId].annualRate / 100 ether);
    payable(ownerOf(_tokenId)).transfer(address(this).balance);
    emit Withdraw(_tokenId, ownerOf(_tokenId), borrowInfo[_tokenId].stakeId);
    _burn(_tokenId);
  }

  function multiWithdrawPayOff(uint256[] memory _tokenIds) public onlyRole(OPERATOR_ROLE) {
    for (uint256 i = 0; i < _tokenIds.length; i++) {
      IGroFiStakingManager(stakingManager).withdraw(_tokenIds[i]);
      payable(vault).transfer(borrowInfo[_tokenIds[i]].amountBorrow + borrowInfo[_tokenIds[i]].amountBorrow * packageInfo[borrowInfo[_tokenIds[i]].packageId].annualRate / 100 ether);
      payable(ownerOf(_tokenIds[i])).transfer(address(this).balance);
      emit Withdraw(_tokenIds[i], ownerOf(_tokenIds[i]), borrowInfo[_tokenIds[i]].stakeId);
      _burn(_tokenIds[i]);
    }
  }

  function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721Upgradeable, AccessControl) returns (bool) {
    return super.supportsInterface(interfaceId);
  }

  function _msgSender() internal view override(Context, ContextUpgradeable)
      returns (address sender) {
      sender = ContextUpgradeable._msgSender();
  }

  function _msgData() internal view override(Context, ContextUpgradeable)
      returns (bytes calldata) {
      return ContextUpgradeable._msgData();
  }

  function onERC721Received(
    address,
    address,
    uint256,
    bytes memory
  ) external pure returns (bytes4) {
      return this.onERC721Received.selector;
  }

  function _beforeTokenTransfer(
    address from,
    address to,
    uint256 tokenId,
    uint256 batchSize
  ) internal virtual override {
    super._beforeTokenTransfer(from, to, tokenId, batchSize);
    if (from != address(0) && to != address(0)) {
      require(borrowInfo[tokenId].borrowAt + packageInfo[borrowInfo[tokenId].packageId].period >= block.timestamp, "E4");
    }
  }

  function tokenURI(
        uint256 _tokenId
    ) public view virtual override returns (string memory) {
      return
        ILoanNFTDescriptor(nftDes).constructTokenURI(
          ILoanNFTDescriptor.ConstructTokenURIParams(
            _tokenId,
            borrowInfo[_tokenId].amountBorrow,
            mustReturn(_tokenId),
            borrowInfo[_tokenId].borrowAt,
            packageInfo[borrowInfo[_tokenId].packageId].period / 1 days,
            borrowInfo[_tokenId].borrowAt + packageInfo[borrowInfo[_tokenId].packageId].period,
            packageInfo[borrowInfo[_tokenId].packageId].annualRate,
            IGroFiStakingManager(stakingManager).uriInfoById(borrowInfo[_tokenId].stakeId).amount
          )
        );
  }
}