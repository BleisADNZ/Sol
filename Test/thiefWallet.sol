pragma solidity 0.4.23;

contract Steal 
{
    address thief = address(0);

    function () payable 
    {
        thief.send(msg.value);
    }
}
