// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Storage {
    uint256 temp;

    function store(uint256 num) public {
        temp = num;
    }

    function retrieve() public view returns (uint256) {
        return temp;
    }
}
