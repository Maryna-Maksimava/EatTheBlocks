pragma solidity 0.8.26;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Icharity} from "./Icharity.sol";

contract Wallet is Ownable {
    Icharity public immutable charity;

   uint256 public constant CHARITY_PERCENTAGE = 50; //5.0%

   error NotEnoughDeposit();
   error NotEnoughMoney();
   error TransferFailed();


    constructor(address charityAddress) Ownable(msg.sender){
        charity = Icharity(charityAddress);
    }

    function deposit() external payable {
        if(msg.value == 0)
        {
            revert NotEnoughDeposit();
        }
        uint256 charityAmount = (msg.value * CHARITY_PERCENTAGE)/1000;
        charity.donate{value:charityAmount}();
    }

    function withdraw (uint256 amount) external onlyOwner{
        if(amount > address(this).balance) revert NotEnoughMoney();
        (bool success, ) = payable(msg.sender).call{value: amount}("");
            if (!success) revert TransferFailed();
    }

}