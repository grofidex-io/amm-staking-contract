// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.13;
pragma abicoder v2;

interface IVault {
    function withdraw(uint256 amount) external ;
}
