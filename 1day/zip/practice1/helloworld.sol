pragma solidity 0.8.26;

contract Helloname{
    function hi(string calldata name) external pure returns(string memory)
    {
        return name;
    }
}