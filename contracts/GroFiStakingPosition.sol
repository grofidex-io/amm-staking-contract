// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "./interface/SFCI.sol";

contract GroFiStakingPosition {
    address public stakingContract;
    address public sfcContract;
    uint256 public remainingStake;
    uint256 public wrID;
    constructor(address _sfcContract, address _stakingContract) {
        stakingContract = _stakingContract;
        sfcContract = _sfcContract;
    }

    function onlyStaking() internal view {
        require(msg.sender == stakingContract);
    }

    function stake(uint256 _toValidatorID) public payable {
        onlyStaking();
        SFCI(sfcContract).delegate{value: msg.value}(_toValidatorID);
    }

    function getStake(uint256 _toValidatorID) public view returns (uint256) {
        return SFCI(sfcContract).getStake(address(this), _toValidatorID);
    }

    function pendingReward(
        uint256 _toValidatorID,
        uint32 _percent
    ) public view returns (uint256) {
        return SFCI(sfcContract).pendingRewards(address(this), _toValidatorID) * (100 - _percent) / 100;
    }

    function unStake(uint256 _toValidatorID, uint256 _amount) public {
        onlyStaking();
        remainingStake += _amount;
        wrID = block.timestamp;
        SFCI(sfcContract).undelegate(_toValidatorID, wrID, _amount);
    }

    function claimReward(uint256 _toValidatorID, address _user, address _vault, uint32 _percent) public {
        onlyStaking();
        SFCI(sfcContract).claimRewards(_toValidatorID);
        payable(_vault).transfer(address(this).balance * _percent / 100);
        payable(_user).transfer(address(this).balance);
    }

    function withdraw(uint256 _toValidatorID, address _user) public {
      require(wrID != 0);
      onlyStaking();
      SFCI(sfcContract).withdraw(_toValidatorID, wrID);
      remainingStake = 0;
      wrID = 0;
      payable(_user).transfer(address(this).balance);
    }
    receive() external payable {}
}
