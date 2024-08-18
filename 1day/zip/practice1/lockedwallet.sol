pragma solidity 0.8.26;

    contract lockedWallet{
        address payable public beneficiary;
        uint256 public withdrawalTime;
        error withdrawTimeNotReachedYet(uint timeRemaining);
        error transferFailed();

        constructor(address payable _beneficiary, uint256 offset) payable{
            beneficiary = _beneficiary;
            withdrawalTime = block.timestamp + offset;
        }

        function withdraw() external {
            if (withdrawalTime > block.timestamp) {
                revert withdrawTimeNotReachedYet(withdrawalTime - block.timestamp);
            }
            (bool success, ) = beneficiary.call{value : address(this).balance}("");
            
            if(!success)
            {
                revert transferFailed();
            }
        }
      
    }