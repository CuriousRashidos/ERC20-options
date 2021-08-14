//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract Greeter {
    string greeting;
    mapping(uint256 => uint256) public lists;
    uint256 private index;

    constructor(string memory _greeting) {
        console.log("Deploying a Greeter with greeting:", _greeting);
        greeting = _greeting;
        //index = 0
        lists[index] = 3;
        index++;
        lists[index] = 4;
    }

    function greet()
        public
        pure
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        return (5, 4, 6);
    }

    function setGreeting(string memory _greeting) public {
        console.log("Changing greeting from '%s' to '%s'", greeting, _greeting);
        greeting = _greeting;
    }
}
