// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

interface IERC2981Royalties {
    function royaltyInfo(
        uint256 tokenID,
        uint256 value
    ) external view returns (address receiver, uint256 royaltyAmount);
}
