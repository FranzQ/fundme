//SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library PriceConverter{
    function getETHPrice() internal view returns (uint256){
        //Address of ETH price feed contract on Goerli Testnet - 0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e
        AggregatorV3Interface pricefeed = AggregatorV3Interface(0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e);
        //latestRoundData() from AggregatorV3Interface.sol returns 5 variables; Use commas to escape
        //Refer to AggregatorV3Interface.sol to check return types
        (,int256 price,,,) = pricefeed.latestRoundData();
        //int256 price will return 1e8
        //Multiply int256 price with 1e10 to match msg.sender decimal places
        return uint256(price * 1e10);
    }

    //Accepts ETH value and returns equivalent in USD 1e18
    function getConversionRate(uint256 ethValue) internal view returns (uint256){
        uint256 ethPrice = getETHPrice();
        uint256 ethValue_Usd = (ethPrice * ethValue) / 1e18;
        return ethValue_Usd;
    }
}