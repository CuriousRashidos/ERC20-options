// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0;

interface IOption {
    function optionDetails() external returns (
            address,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        );
}
