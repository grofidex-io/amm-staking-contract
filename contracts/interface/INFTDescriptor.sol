// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.13;
pragma abicoder v2;

interface INFTDescriptor {
    struct ConstructTokenURIParams {
        uint256 tokenId;
        uint256 amount;
        uint256 issueAt;
        address user;

    }

    function constructTokenURI(ConstructTokenURIParams memory params) external pure returns (string memory);
}
