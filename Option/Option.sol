// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "./IMicrosoft.sol";

//remove full amount
//remove overrides

contract Option is ERC20 {
    event CollateralRecieved(uint256 amount);
    event OptionBought(address boughtBy);

    event OptionExercised(
        address exercisor,
        uint256 spot,
        uint256 strike,
        uint256 profit
    );

    uint256 strike;
    uint256 optionType;
    uint256 expiry;
    uint256 premium;
    uint256 amount;
    address writer;

    IMicrosoft microsoft;

    modifier hasTokens() {
        require(balanceOf(msg.sender) > 0, "No tokens");
        _;
    }

    receive() external payable {
        emit CollateralRecieved(msg.value);
    }

    modifier validPurchase() {
        uint256 supply = totalSupply();
        require(msg.value == premium, "Pay premium");
        require(supply == 0, "Already purchased");
        _;
    }

    constructor(
        address _writer,
        uint256 _type,
        uint256 _strike,
        uint256 _prem,
        uint256 _expiry,
        uint256 _amount,
        address _assetAddress
    ) ERC20("MSFT Options", "MSFT-OP") {
        strike = _strike;
        writer = _writer;
        optionType = _type;
        expiry = _expiry;
        amount = _amount;
        premium = _prem * _amount;
        microsoft = IMicrosoft(_assetAddress);
    }

    function buy() external payable validPurchase {
        require(optionType != 0, "Already exercised");
        require(block.timestamp < expiry, "Option expired");

        _mint(msg.sender, amount * 10**18);
        (bool success, ) = payable(writer).call{value: msg.value}("");
        require(success, "Option: Payment fail");
        emit OptionBought(msg.sender);
    }

    function exercise() external payable hasTokens {
        require(optionType != 0, "Already exercised");
        require(
            block.timestamp >= expiry - 1 hours,
            "Exercise window not reached"
        );
        require(block.timestamp < expiry, "Option expired");

        uint256 _type = optionType;
        uint256 _strike = strike;
        uint256 _spot = microsoft.getPrice();
        uint256 payout;

        if (_type == 1) {
            require(_spot <= _strike, "Loss incurred for PUT");
            payout = _strike - _spot;
        } else if (_type == 2) {
            require(_spot >= _strike, "Loss incurred for CALL");
            payout = _spot - _strike;
        }

        (bool success2, ) = payable(msg.sender).call{value: payout * amount}(
            ""
        );
        (bool success1, ) = payable(writer).call{value: address(this).balance}(
            ""
        );

        require(success1, "writer payment failed");
        require(success2, "exercisor payment failed");

        optionType = 0;
        _burn(msg.sender, balanceOf(msg.sender));

        emit OptionExercised(msg.sender, _spot, _strike, payout * amount);
    }

    function optionDetails()
        external
        view
        returns (
            address,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        return (address(this), optionType, strike, expiry, premium, amount);
    }

    function contractBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
