//This contract allows users to deposit funds into the contract
//Contract deployer is the onl;y one who can withdraw funds

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;
import "./PriceConverter.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";

/*
Good Practices
- Use 'constant' and 'immutable' to reduce gas
*/

error WithdrawFailed();

contract FundMe is Ownable{
    constructor(){

    }

    using PriceConverter for uint256;
    //Set mimimun deposit amount  - 10 USD
    //Since solidity doesn't work with decimal plcaes, use base 18
    uint256 public constant MIN_USD = 10 * 1e18;
    address[] public funders;
    mapping(address => uint256) public addressToAmountFunded;

    function fund() public payable{
        //Require mimimun deposit amount
        //Function will revert with messsage if requirement fails -> Gas will be returned
        //msg.value will return 1e18
        require(msg.value.getConversionRate() >= MIN_USD, "Minimun Insufficient"); //1 x 10 x 18 = 100000000000000000 Wei
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] += msg.value;
    }
    
    function withdraw() public onlyOwner{
        //Transfer - Caps at 2300 gas, Throws error
        //payable(msg.sender).transfer(address(this).balance);

        //Send - Caps at 2300 gas, Returns boolean
        //bool sent = payable(msg.sender).send(address(this).balance);
        //require(sent, "Withdrawal failed");

        //Call - Forawards all gas or set gas, Returns boolean
        (bool callSuccess,) = payable(msg.sender).call{value: address(this).balance}("");
        if(callSuccess == false) {
            revert WithdrawFailed();
        }
    }

    //If msg.data is null
    //This special function is triggered if a transaction is sent without data i.e the dedicated function to receive and process deposits
    receive() external payable{
        //Send donation to contract creator
        payable(owner()).transfer(msg.value);
    }

    //This special function is triggered if no msg.data is empty
    fallback() external payable{
        //Send donation to contract creator
        payable(owner()).transfer(msg.value);
    }
}