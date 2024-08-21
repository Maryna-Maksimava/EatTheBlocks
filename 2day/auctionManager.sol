pragma solidity 0.8.26;

import "./Auction.sol";

contract ActionManager is Ownable{
    Auction[] auctions;
    uint256 feePercentage;

    error InvalidAuctionIndex();
    error OnlyOwner();
    error NoBalance();
    error TransferFailed();

    event AuctionCreated(address auctionAddress);

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

    function getAuctionsCount() public view returns(uint) {
        return auctions.length;
    }

    function getAuction(uint256 index) public view returns(address) {
        if (index >= auctions.length) revert InvalidAuctionIndex();       
        return address(auctions[index]);
     }

     function setFeePercentage(uint256 _feePercentage) external onlyOwner {
        feePercentage = _feePercentage;
     }

     function withdraw() external onlyOwner {
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