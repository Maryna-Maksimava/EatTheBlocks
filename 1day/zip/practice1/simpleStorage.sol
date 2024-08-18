pragma solidity 0.8.26;

contract SimpleStorage{
    uint256 storedData;

    function set(uint256 newData) external {
        storedData = newData;
    }

    
    function get() external view returns(uint256){
        return storedData;
    }
}