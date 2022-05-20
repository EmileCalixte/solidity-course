//SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0 <0.9.0;

contract CryptosToken {
    string public constant name = "Cryptos";
    address public owner;
    uint supply;

    constructor() {
        owner = msg.sender;
        supply = 0;
    }

    function getSupply() public view returns(uint) {
        return supply;
    }

    function setSupply(uint newSupply) public {
        supply = newSupply;
    }
}
