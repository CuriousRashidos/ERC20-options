// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Microsoft {
    uint256 assetPrice = 0.01 ether;

    function setPrice(uint256 _newPrice) public returns (uint256) {
        assetPrice = _newPrice;
        return _newPrice;
    }

    function getPrice() public view returns (uint256) {
        return assetPrice;
    }
}
