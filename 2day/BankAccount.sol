pragma solidity 0.8.26;

contract BankAccount{
    mapping(address => uint256) balances;

    error TransferFailed();
    error NotOwner();
    error NotEnoughBalance();
    error ZeroEther();

    event Transfer(address from, address to, uint _amount);
    event Withdrawal(address account, uint _amount);
    event Deposit(address account, uint _amount);

    function deposit() payable external{
        if(msg.value == 0) revert ZeroEther();
        emit Deposit(msg.sender, msg.value);
        balances[msg.sender] += msg.value;  
    }

    function withdraw(uint256 _amount) external{
        if (_amount <= 0 || _amount > balances[msg.sender]) revert NotEnoughBalance();
        (bool success, ) = payable(msg.sender).call{value: _amount}("");
        if (!success){revert TransferFailed();}
        balances[msg.sender] -= _amount;
        emit Withdrawal(msg.sender, _amount);
    }

    function getBalance() public view returns (uint){
        return balances[msg.sender];
    }

    function getBalanceOf(address _address) public view returns (uint){
        return balances[_address];
    }

}