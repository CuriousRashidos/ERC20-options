// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0;

interface ILiquidityManager {
    function provide(address _address, uint256 _amount)
        external
        payable
        returns (bool);

    function claimPremium(address _address) external payable returns (uint256);
}
