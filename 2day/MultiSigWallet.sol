pragma solidity 0.8.26;

contract MultiSigWallet{
    address[] owners;
    mapping(address=>bool) isOwner;
    uint256 requiredApprovals;
    struct Transaction {
        address to;
        uint256 value;
        bytes data;
        bool executed;
        uint256 approvals;
    }

    Transaction[] transactions;
    mapping (uint256 => mapping(address => bool)) txApprovals;

    modifier onlyOwners(){
        if (!isOwner[msg.sender]){
            revert NotOwner();
         }
        _;
    }

    error NotOwner();
    error AlreadyApproved();
    error TransactionAlreadyExecuted();
    error InvalidTransaction();
    error InvalidOwner();
    error InsufficientApprovals();
    error TransferFailed();
    error InvalidRequiredApprovals();
    error InvalidAddress();

    event Deposit(address sender, uint256 amount);
    event TransactionSubmitted(uint256 transID, address to, uint256 value, bytes data);
    event ApprovalReceived(uint256 transID, address owner);
    event TransactionExecuted(uint256 transID);

    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }

    constructor( address[] memory _owners, uint256 _requiredApprovals ){
        if (_owners.length == 0) {
            revert InvalidOwner();
        }
        
        owners  = _owners;
        for (uint256 i = 0; i < _owners.length; i++) {
            address owner = _owners[i];
            if (owner == address(0) || isOwner[owner]) {
                revert InvalidOwner();
            }
            isOwner[owner] = true;
            owners.push(owner);
        }
        if (_requiredApprovals == 0 || _requiredApprovals > owners.length) {
            revert InvalidRequiredApprovals();
        }
        requiredApprovals = _requiredApprovals;
        
    }
    


    function submitTransaction(address _to, uint256 _value, bytes memory _data) external onlyOwners{
        if(_value == 0){
            revert InvalidTransaction();
        }
        if(_to == address(0)){
            revert InvalidAddress();
        }
        
        transactions.push(Transaction(_to, _value, _data, false, 1));
        uint256 length = transactions.length;
        transactions[length -1].approvals = 1;
        txApprovals[length - 1][msg.sender] = true;
        emit TransactionSubmitted(transactions[transactions.length -1].approvals, _to, _value, _data);
    }

    function approveTransaction(uint256 _transID) external onlyOwners{
        if(_transID >= transactions.length){
            revert InvalidTransaction();
         }
         if (transactions[_transID].executed){
            revert TransactionAlreadyExecuted();
         }
         if (txApprovals[_transID][msg.sender]){
            revert AlreadyApproved();
         }
         transactions[_transID].approvals += 1;
         txApprovals[_transID][msg.sender] = true;
         emit ApprovalReceived(_transID, msg.sender);
     }

    function executeTransaction(uint256 _transID) external onlyOwners{
        if(_transID >= transactions.length){
            revert InvalidTransaction();
        }
        if (transactions[_transID].executed){
            revert TransactionAlreadyExecuted();
        }
        if(transactions[_transID].approvals < (requiredApprovals)){
            revert InsufficientApprovals();
        }
        (bool success, ) = payable(transactions[_transID].to).call{ value: transactions[_transID].value }(transactions[_transID].data);
        if (!success) revert TransferFailed();
            
          transactions[_transID].executed = true;
          emit TransactionExecuted(_transID);
    }

    function getTransactionCount() external view returns (uint256){
        return transactions.length;
    }

    function getTransaction(uint256 id)  public
        view
        returns (
            address to,
            uint256 value,
            bytes memory data,
            bool executed,
            uint256 approvals
        )
    {
        Transaction storage transaction = transactions[id];
        return (
            transaction.to,
            transaction.value,
            transaction.data,
            transaction.executed,
            transaction.approvals
        );
    }
}