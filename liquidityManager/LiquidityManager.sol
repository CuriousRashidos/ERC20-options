// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0;

//making a contract PoolManager
//keeps track of options and the collateral provided and buy whome
//can also store all options which im storing in options protocol
//mapping - numOf options, numOF

//writer first providers inital liquidity for atleast 1

import "./IMicrosoft.sol";
import "./IOption.sol";
import "./SafeMath.sol";

contract LiquidityManager {
    using SafeMath for uint256;

    uint256 public numOfOptions;
    IMicrosoft microsoft =
        IMicrosoft(0xbA8dC1a692093d8aBD34e12aa05a4fE691121bB6);
    IOption option;

    mapping(uint256 => address) public options;
    mapping(address => mapping(address => uint256)) public liquidityPool;
    mapping(address => uint256) public optionPremium;
    mapping(address => uint256) public optionLiquidity;

    function provide(address _address, uint256 _amount)
        external
        payable
        returns (bool)
    {
        option = IOption(_address);
        (, , uint256 expiry, , , ) = option.optionDetails();
        uint256 price = microsoft.getPrice();

        require(block.timestamp < expiry, "Liquidity M: Option expired");
        require(
            msg.value * _amount == price * _amount,
            "Liquidity M: Unequal Colletaral"
        );

        liquidityPool[_address][msg.sender] += msg.value;
        optionLiquidity[_address] += msg.value;
        return true;
    }

    function claimPremium(address _address) external payable returns (uint256) {
        require(
            liquidityPool[_address][msg.sender] != 0,
            "Liquidity M: No liquidity provided"
        );
        uint256 totalPremium = optionPremium[_address];
        uint256 poolShare = liquidityPool[_address][msg.sender] * 1000;
        uint256 totalLiquidity = optionLiquidity[_address];

        uint256 percent = poolShare.div(totalLiquidity);
        uint256 payout = (percent * totalPremium) / 1000;

        return payout;
    }

    // function claimPremium(uint _input)public pure returns(uint){
    //     uint total = 2 ether;
    //     uint input = 1000 * _input;
    //     uint premium = 0.15 ether;
    //     uint payout = (input.div(total) * premium)/1000;
    //     return payout;

    // }
}
