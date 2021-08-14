// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0;

import './IMicrosoft.sol';
import './Option.sol';
import './ILiquidityManager.sol';

contract OptionsProtocol {
    event OptionCreated(
        address optionAddress,
        uint256 optionType,
        uint256 strike,
        uint256 premium,
        uint256 expiry,
        uint256 amount
    );
    uint256 _numOfOptions;
    mapping(uint256 => uint256) public options;
    
    IMicrosoft microsoft = IMicrosoft(0xd8b934580fcE35a11B58C6D73aDeE468a2833fa8);
    ILiquidityManager liquidityManager = ILiquidityManager(0xf8e81D47203A594245E36C48e151709F0C19fBe8);

    modifier validOption(
        uint256 _strike,
        uint256 _optionType,
        uint256 _expiry,
        uint256 _amount
       
    ) {
        uint price = microsoft.getPrice();
        require(msg.value == price * _amount, "Unequal Collateral");
        if (_optionType == 1)
            require(_strike < price, "Strike > price for PUT");
        if (_optionType == 2)
            require(_strike > price, "Strike < price for CALL");
        require(_expiry == 1 || _expiry == 2, "Invalid Expiry");
        _;
    }


    /*
    @param optionType - 1 = put, 2 = call
    @param strike 
    @param prem p- premium that the option buyer payers
    @param expiry - expiration point of the option 
    @param amount - amount of options/tokens
     */
    function writeOption(
        uint256 _optionType,
        uint256 _strike,
        uint256 _prem,
        uint256 _expiry,
        uint256 _amount
    )
        external
        payable
        validOption(_strike, _optionType, _expiry, _amount)
    {
        uint256 expiry;
        _expiry == 1 ? expiry = _hour1() : expiry = _day1();
        Option option = new Option(
            msg.sender,
            _optionType,
            _strike,
            _prem,
            expiry,
            _amount,
            address(microsoft)
        );
        (bool success, ) = payable(address(option)).call{value: msg.value}("");
        require(success, "Protocol: Fail to transfer collateral");
        
        liquidityManager.provie()

        options[_numOfOptions] = uint256(uint160(address(option)));
        _numOfOptions++;

        emit OptionCreated(
            address(option),
            _optionType,
            _strike,
            _prem,
            _expiry,
            _amount
        );
    }

    function _hour1() private view returns (uint256) {
        return block.timestamp + 1 hours;
    }

    function _day1() private view returns (uint256) {
        return block.timestamp + 1 days;
    }

    function uintToAddress(uint256 _address) external pure returns (address) {
        return address(uint160(_address));
    }
}
