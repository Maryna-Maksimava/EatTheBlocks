// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Auction} from "./Auction.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract AuctionManager is Ownable {
    Auction[] auctions;

    uint256 public feePercentage = 5;

    event AuctionCreated(address auctionAddress);

    error InvalidAuctionIndex();
    error OnlyOwner();
    error NoBalance();
    error TransferFailed();

    constructor() Ownable(msg.sender) {}

    function createAuction() public {
        Auction newAuctionContract = new Auction(
            msg.sender,
            address(this),
            feePercentage
        );
        auctions.push(newAuctionContract);
        emit AuctionCreated(address(newAuctionContract));
    }

    function getAuctionsCount() public view returns (uint256) {
        return auctions.length;
    }

    function getAuction(uint256 _index) public view returns (address) {
        if (_index >= auctions.length) {
            revert InvalidAuctionIndex();
        }
        return address(auctions[_index]);
    }

    function setFeePercentage(uint256 _feePercentage) public {
        feePercentage = _feePercentage;
    }

    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        if (balance == 0) {
            revert NoBalance();
        }
        (bool success, ) = payable(msg.sender).call{value: balance}("");
        if (!success) {
            revert TransferFailed();
        }
    }

    receive() external payable {}
}
