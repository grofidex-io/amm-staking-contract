// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.13;
pragma abicoder v2;

interface ILoanNFTDescriptor {
    struct ConstructTokenURIParams {
        uint256 tokenId;
        uint256 amount;
        uint256 amountReturn;
        uint256 issueAt;
        uint256 period;
        uint256 repayTime;
        uint256 annualRate;
        uint256 stakeAmount;
    }

    function constructTokenURI(ConstructTokenURIParams memory params) external pure returns (string memory);
}
