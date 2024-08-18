pragma solidity 0.8.26;

contract Counter{
    uint256 count;

    function increment() external {
        count +=1;
    }

    function decrement() external {
        require (count > 0, "count should be greater than zero");
        count -=1;
    }

    function show() external view returns(uint){
        return count;
    }
}