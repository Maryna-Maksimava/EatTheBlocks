//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

contract InheritanceContract {
    address payable public Recipient;
    address public owner;
    bool public isOwnerDeceased;

    constructor(address payable recipient)
    {
        owner = msg.sender;
        Recipient = recipient;
        isOwnerDeceased = false;

    }

    modifier onlyOwner()
    {
        require(msg.sender == owner, "Only the owner can access this function");
        _;
    }

    modifier onlyRecipient ()
    {
        require (msg.sender == Recipient, "Only designated recipient can access this function");
        _;
    }

    function declareDeceased() external onlyOwner 
    {
        require(isOwnerDeceased, "The owner have not been declared deceased");
        require(address(this).balance > 0, "no funds available for withdrawal" );
        Recipient.transfer(address(this).balance);
    }


//fallback function to receive payments
    receive () external payable{}


}