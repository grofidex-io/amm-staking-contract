// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/AccessControl.sol";

contract Vault is AccessControl {
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");

    constructor(address _admin) {
      _grantRole(DEFAULT_ADMIN_ROLE, _admin);
      _grantRole(OPERATOR_ROLE, _admin);
    }

    function withdraw(uint256 amount) public onlyRole(OPERATOR_ROLE)  {
      require(amount <= address(this).balance, "Not enough balance in vault");
      payable(msg.sender).transfer(amount);
    }

    function withdrawAll() public onlyRole(OPERATOR_ROLE)  {
      payable(msg.sender).transfer(address(this).balance);
    }

    receive() external payable {}
}
