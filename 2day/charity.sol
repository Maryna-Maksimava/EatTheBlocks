pragma solidity 0.8.26;

contract Charity {
    mapping(address => uint256) userDonations;
    address owner;

    modifier onlyOwner{
        require (msg.sender == owner);
        _;
    }

    error NotEnoughDonation();
    error TransferFailed();
    error NotEnoughMoney();

    event Donated(address indexed donor, uint256 amount);

    function donate() external payable {
        if (msg.value == 0) revert NotEnoughDonation();
        address donor = msg.sender;
        userDonations[donor] += msg.value;
        emit Donated(donor, msg.value);
    }

    function withdraw (uint256 amount) external onlyOwner{
        if(amount > address(this).balance) revert NotEnoughMoney();
        (bool success, ) = payable(owner).call{value: amount}("");
            if (!success) revert TransferFailed();
    }

    constructor()  {
        owner = msg.sender;
    }


}