// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "./interface/INFTDescriptor.sol";
import "./GroFiStakingPosition.sol";
import "@openzeppelin/contracts/utils/Arrays.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

///MSG CODE
///S1: Not Admin
///S2: Invalid in amount
///S3: Not staker
///S4: Time invalid

contract GroFiStakingManager is AccessControl, ERC721Upgradeable {
    using Arrays for uint256[];
    using Counters for Counters.Counter;

    struct Snapshots {
        uint256[] ids;
        uint256[] values;
    }

    mapping(address => Snapshots) private _accountBalanceSnapshots;
    Snapshots private _totalSupplySnapshots;

    // Snapshot ids increase monotonically, with the first value being 1. An id of 0 is invalid.
    Counters.Counter private _currentSnapshotId;

    event Snapshot(uint256 id);

    event Stake(
        uint256 indexed tokenId,
        address indexed staker,
        uint256 indexed amount,
        uint256 toValidatorID,
        address contractStake
    );
    event UnStake(
        uint256 indexed tokenId,
        address indexed staker,
        uint256 indexed amount,
        uint256 toValidatorID
    );
    event ClaimReward(
        uint256 indexed tokenId,
        address indexed staker,
        uint256 indexed reward,
        uint256 toValidatorID
    );
    event Withdraw(
        uint256 indexed tokenId,
        address indexed staker,
        uint256 toValidatorID
    );
    event BurnNFT(uint256 indexed tokenId, address contractStake);

    address public sfcContract;
    address public admin;
    address public vault;
    address public nftDes;

    uint256 public currentTokenId;
    uint256 public validator;
    uint32 public percentVault;

    mapping(uint256 => address) public addressByTokenId;
    mapping(address => uint256) public contractAvail;
    mapping(uint256 => uint256) public validatorById;
    mapping(uint256 => UriInfo) public uriInfoById;

    mapping(address => uint256) public stakeOf;

    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");

    function updateAdminAccess() public {
      require(msg.sender == admin, "S1");
      _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
      _grantRole(OPERATOR_ROLE, msg.sender);
    }

    struct UriInfo {
        uint256 amount;
        uint256 issueAt;
    }

    function initialize(
        address _sfcContract,
        address _admin,
        address _vault,
        address _nftDes,
        uint256 _validator,
        uint32 _percentVault
    ) public initializer {
        __ERC721_init("GroFi_Staking_NFT", "GROFI_STAKING_NFT");
        sfcContract = _sfcContract;
        admin = _admin;
        validator = _validator;
        vault = _vault;
        percentVault = _percentVault;
        nftDes = _nftDes;
    }

    function snapshot() public {
      require(msg.sender == admin, "S1");
      _snapshot();
    }

    function _snapshot() internal virtual returns (uint256) {
        _currentSnapshotId.increment();

        uint256 currentId = _getCurrentSnapshotId();
        emit Snapshot(currentId);
        return currentId;
    }

    /**
     * @dev Get the current snapshotId
     */
    function _getCurrentSnapshotId() internal view virtual returns (uint256) {
        return _currentSnapshotId.current();
    }

    /**
     * @dev Retrieves the balance of `account` at the time `snapshotId` was created.
     */
    function stakeOfAt(address account, uint256 snapshotId) public view virtual returns (uint256) {
        (bool snapshotted, uint256 value) = _valueAt(snapshotId, _accountBalanceSnapshots[account]);

        return snapshotted ? value : stakeOf[account];
    }

    function _valueAt(uint256 snapshotId, Snapshots storage snapshots) private view returns (bool, uint256) {
        require(snapshotId > 0);
        require(snapshotId <= _getCurrentSnapshotId());

        uint256 index = snapshots.ids.findUpperBound(snapshotId);

        if (index == snapshots.ids.length) {
            return (false, 0);
        } else {
            return (true, snapshots.values[index]);
        }
    }

    function _updateAccountSnapshot(address account) private {
        _updateSnapshot(_accountBalanceSnapshots[account], stakeOf[account]);
    }

    function _updateSnapshot(Snapshots storage snapshots, uint256 currentValue) private {
        uint256 currentId = _getCurrentSnapshotId();
        if (_lastSnapshotId(snapshots.ids) < currentId) {
            snapshots.ids.push(currentId);
            snapshots.values.push(currentValue);
        }
    }

    function _lastSnapshotId(uint256[] storage ids) private view returns (uint256) {
        if (ids.length == 0) {
            return 0;
        } else {
            return ids[ids.length - 1];
        }
    }

    function updateNFT(address _nftDes) public {
        require(msg.sender == admin, "S1");
        nftDes = _nftDes;
    }

    function updateAdmin(address _admin) public {
        require(msg.sender == admin, "S1");
        admin = _admin;
    }

    function updateConfig(
        uint256 _validator,
        address _vault,
        uint32 _percentVault
    ) public {
        require(msg.sender == admin, "S1");
        validator = _validator;
        vault = _vault;
        percentVault = _percentVault;
    }

    function withdrawalPeriodTime() external view returns (uint256) {
        address constAddress = SFCI(sfcContract).constsAddress();
        return SFCI(constAddress).withdrawalPeriodTime();
    }

    function stake(address _staking) public payable returns(uint256) {
        require(msg.value >= 1000000000000, "S2");
        currentTokenId++;
        _safeMint(msg.sender, currentTokenId);
        validatorById[currentTokenId] = validator;
        //deploy
        if (_staking == address(0)) {
          GroFiStakingPosition staking = new GroFiStakingPosition(
            sfcContract,
            address(this)
          );
          contractAvail[address(staking)] = currentTokenId;
          addressByTokenId[currentTokenId] = address(staking);
          staking.stake{value: msg.value}(validator);
          emit Stake(currentTokenId, msg.sender, msg.value, validator, address(staking));
        } else {
          require(contractAvail[_staking] == 0);
          contractAvail[_staking] = currentTokenId;
          addressByTokenId[currentTokenId] = address(_staking);
          GroFiStakingPosition(payable(_staking)).stake{value: msg.value}(validator);
          emit Stake(currentTokenId, msg.sender, msg.value, validator, _staking);
        }
        uriInfoById[currentTokenId].amount = msg.value;
        uriInfoById[currentTokenId].issueAt = block.timestamp;
        _updateAccountSnapshot(msg.sender);
        stakeOf[msg.sender] += msg.value;
        return currentTokenId;
    }

    function unStake(uint256 _tokenId) public {
        require(msg.sender == ownerOf(_tokenId), "S3");
        require(addressByTokenId[_tokenId] != address(0), "S4");
      
        if (GroFiStakingPosition(payable(addressByTokenId[_tokenId])).pendingReward(validatorById[_tokenId], percentVault) != 0) {
          GroFiStakingPosition(payable(addressByTokenId[_tokenId])).claimReward(
            validatorById[_tokenId],
            msg.sender,
            vault,
            percentVault
          );
        }
        emit UnStake(
            _tokenId,
            msg.sender,
            GroFiStakingPosition(payable(addressByTokenId[_tokenId])).getStake(
                validatorById[_tokenId]
            ),
            validatorById[_tokenId]
        );
        GroFiStakingPosition(payable(addressByTokenId[_tokenId])).unStake(
            validatorById[_tokenId],
            GroFiStakingPosition(payable(addressByTokenId[_tokenId])).getStake(
                validatorById[_tokenId]
            )
        );
        _updateAccountSnapshot(msg.sender);
        if (stakeOf[msg.sender] <= uriInfoById[_tokenId].amount) {
          stakeOf[msg.sender] = 0;
        } else stakeOf[msg.sender] -= uriInfoById[_tokenId].amount;
        uriInfoById[_tokenId].amount = 0;
    }

    function withdraw(uint256 _tokenId) public {
        require(msg.sender == ownerOf(_tokenId), "S3");
        require(addressByTokenId[_tokenId] != address(0), "S4");
        emit Withdraw(_tokenId, msg.sender, validatorById[_tokenId]);
        GroFiStakingPosition(payable(addressByTokenId[_tokenId])).withdraw(
            validatorById[_tokenId],
            msg.sender
        );
        if (
            GroFiStakingPosition(payable(addressByTokenId[_tokenId])).getStake(
                validatorById[_tokenId]
            ) == 0 &&
            GroFiStakingPosition(payable(addressByTokenId[_tokenId]))
                .pendingReward(validatorById[_tokenId], percentVault) == 0 &&
            GroFiStakingPosition(payable(addressByTokenId[_tokenId]))
                .remainingStake() == 0
        ) {
            _burn(_tokenId);
            contractAvail[addressByTokenId[_tokenId]] = 0;
            emit BurnNFT(_tokenId, addressByTokenId[_tokenId]);
        }
    }

    function claimReward(uint256 _tokenId) public {
        require(msg.sender == ownerOf(_tokenId), "S3");
        require(addressByTokenId[_tokenId] != address(0), "S4");
        emit ClaimReward(
            _tokenId,
            msg.sender,
            GroFiStakingPosition(payable(addressByTokenId[_tokenId]))
                .pendingReward(validatorById[_tokenId], percentVault),
            validatorById[_tokenId]
        );
        GroFiStakingPosition(payable(addressByTokenId[_tokenId])).claimReward(
            validatorById[_tokenId],
            msg.sender,
            vault,
            percentVault
        );
    }

    function pendingReward(uint256 _tokenId) external view returns (uint256) {
        return
            GroFiStakingPosition(payable(addressByTokenId[_tokenId]))
                .pendingReward(validatorById[_tokenId], percentVault);
    }

    receive() external payable {}

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);

        if (from != address(0) && to != address(0)) {
            // transfer
            _updateAccountSnapshot(from);
            _updateAccountSnapshot(to);
            stakeOf[from] -= uriInfoById[tokenId].amount;
            stakeOf[to] += uriInfoById[tokenId].amount;
        }
    }

    function tokenURI(
        uint256 _tokenId
    ) public view virtual override returns (string memory) {
        return
            INFTDescriptor(nftDes).constructTokenURI(
                INFTDescriptor.ConstructTokenURIParams(
                    _tokenId,
                    uriInfoById[_tokenId].amount,
                    uriInfoById[_tokenId].issueAt,
                    ownerOf(_tokenId)
                )
            );
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
}
