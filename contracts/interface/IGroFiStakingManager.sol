// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.13;
pragma abicoder v2;

interface IGroFiStakingManager {
    struct UriInfo {
        uint256 amount;
        uint256 issueAt;
    }

    function unStake(uint256 _tokenId) external;

    function withdraw(uint256 _tokenId) external;

    function claimReward(uint256 _tokenId) external;

    function pendingReward(uint256 _tokenId) external view returns (uint256);

    function uriInfoById(uint256 _tokenId) external view returns (UriInfo memory);

    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    function stakeOfAt(address account, uint256 snapshotId) external view returns (uint256);
}
