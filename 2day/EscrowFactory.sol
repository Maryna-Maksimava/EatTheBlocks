pragma solidity 0.8.26;

import {Escrow} from "./Escrow.sol";
contract EscrowFactory {
    Escrow[] escrows;

    error InvalidIndex();

    event EscrowCreated(address escrowAddress);

    function createEscrow(address payer, address escrowAgent, address payee) external{
        Escrow newEscrowContract = new Escrow(payer,escrowAgent, payee);
        escrows.push(newEscrowContract);
        emit EscrowCreated(address(newEscrowContract));
       
    }

    function getEscrowsCount() external view returns(uint256) {
        return escrows.length;
    }

    function getEscrow(uint256 index) external view returns(address) {
        if (index >= escrows.length) revert InvalidIndex();
        return address(escrows[index]);
    }
}