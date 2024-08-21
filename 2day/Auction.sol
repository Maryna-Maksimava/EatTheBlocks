pragma solidity 0.8.26;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract Auction is Ownable{
    address feeAddress;
    uint256 feePercentage;
    uint256 startTime;
    uint256 endTime;
    bool ended;
    address highestBidder;
    uint256 highestBid;
    mapping(address => uint256) bids;
    
    error AuctionAlreadyEnded();
    error AuctionNotYetEnded();
    error BidNotHighEnough(uint256 highestBid);
    error AuctionAlreadyStarted();
    error NoBidToWithdraw();
    error TransferFailed();

    event AuctionStarted(uint256 startTime, uint256 endTime);
    event HighestBidIncreased(address indexed bidder, uint256 amount);
    event AuctionEnded(address winner, uint256 amount);

    function startAuction(uint256 _biddingTime) external {
        if (block.timestamp > startTime) revert AuctionAlreadyStarted();
        startTime = block.timestamp;
        endTime = startTime + _biddingTime;
        emit AuctionStarted(startTime, endTime);
    }

    function bid() external payable {
        if (block.timestamp > endTime)    revert AuctionAlreadyEnded();
        if(msg.value <= highestBid) revert BidNotHighEnough(highestBid);

        if (highestBidder != address(0)) {
            (bool success, ) = payable(highestBidder).call{value: highestBid}(
                ""
            );
            if (!success) {
                revert TransferFailed();
            }
            bids[highestBidder] = 0;
        }

        highestBidder = msg.sender;

        bids[msg.sender] = msg.value;
        highestBid = msg.value;
        emit HighestBidIncreased(msg.sender, msg.value);       
    }

    function calculateFee(uint256 amount) internal view returns (uint256) {
        return (amount * feePercentage) / 100;
    }
    

    function endAuction() external {
        if (block.timestamp <= endTime) {
            revert AuctionNotYetEnded();
        }
        if (ended)    revert AuctionAlreadyEnded();
        if (block.timestamp < endTime)    revert AuctionNotYetEnded();

        uint256 fee = calculateFee(highestBid);
        uint256 amount = highestBid - fee;
        transferFee(fee);
        transferToOwner(amount);

        emit AuctionEnded(highestBidder, highestBid);
        ended = true;
    }

    function transferFee(uint256 fee) internal {
        (bool success, ) = feeAddress.call{value: fee}("");
        if (!success) {
            revert TransferFailed();
        }
    }

    function transferToOwner(uint256 amount) internal {
        (bool success, ) = payable(owner()).call{value: amount}("");
        if (!success) {
            revert TransferFailed();
        }
    }

    constructor(address _ownerAddress, address _feeAddress, uint256 _feePercentage) 
    Ownable(_ownerAddress) {
        feeAddress = _feeAddress;
        feePercentage = _feePercentage;
     }

}