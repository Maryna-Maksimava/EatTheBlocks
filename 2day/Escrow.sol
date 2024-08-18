pragma solidity 0.8.26;

    contract Escrow {
        address public payer;
        address payable public payee;
        address payable public escrowAgent;
        uint256 public amount;
        bool public isFundsDeposited;
        bool public isFundReleased;

        error OnlyEscrowAgent();
        error OnlyPayer();
        error FundsAlreadyDeposited();
        error FundsNotDeposited();
        error DepositAmountZero();
        error FundsAlreadyReleased();
        error TransferFailed();

        event FundsDeposited(address payer, uint256 amount);
        event FundsReleased(address payee, uint256 amount);

        function deposit() external payable {
            if (isFundsDeposited) revert FundsAlreadyDeposited();
            if (msg.value == 0) revert DepositAmountZero();
            if (msg.sender != address(payer)) revert OnlyPayer();
            
            amount = msg.value;
            isFundsDeposited = true;
            emit FundsDeposited(msg.sender, msg.value);            
        }

        constructor(address _payer, address _escrowAgent, address _payee) {
            payer = _payer;
            escrowAgent = payable(_escrowAgent);
            payee = payable(_payee);
        }

        function releaseFunds() external {
            if (!isFundsDeposited) revert FundsNotDeposited();
            if (msg.sender != escrowAgent) revert OnlyEscrowAgent();
            if (isFundReleased) revert FundsAlreadyReleased();
            
            (bool success, ) = payee.call{value: amount}("");
            if (!success) revert TransferFailed();
            
            isFundsDeposited = false;
            isFundReleased = true;
            emit FundsReleased(payee, amount);
            amount = 0;
        }




    }