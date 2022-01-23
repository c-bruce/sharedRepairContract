// SPDX-License-Identifier: GPL-3.0

// Smart contract for organising a shared repair
// Author: Callum Bruce
// Date: 23/01/22

pragma solidity ^0.8.11;

contract SharedRepair {
    uint256 public totalRepairCost = 30; // Total repair cost

    uint256 public shareOfRepairCost; // Share of repair cost (i.e. shareOfRepairCost = 30/3 = 10)

    uint256 public paidCount = 0;

    uint256 public peopleCount = 0;

    mapping(uint => Person) public people;

    address payable contractor;

    modifier owner() {
        require(msg.sender == contractor); // If the person is the contract owner true, else error
        _;
    }

    struct Person {
        uint _id;
        string _name;
        address _address;
        uint256 _contribution;
        bool _paid;
    }

    constructor(address payable _contractor) {
        contractor = _contractor;
        addPerson("Niamh", 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2);
        addPerson("Gordon", 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db);
        addPerson("Gloria", 0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB);
        shareOfRepairCost = totalRepairCost / peopleCount;
    }

    function addPerson(string memory _name, address _address) public owner {
        incrementCount();
        people[peopleCount] = Person(peopleCount, _name, _address, 0, false);
    }

    function deposit() public payable {
        for (uint i=1; i < peopleCount; i++) {
            if (msg.sender == people[i]._address) {
                people[i]._contribution += msg.value / 1e18;
                if (people[i]._contribution >= shareOfRepairCost) {
                    people[i]._paid = true;
                    paidCount ++;
                }
            }
        }
    }

    function withdraw() public payable {
        if (paidCount == peopleCount) {
            contractor.transfer(address(this).balance);
        }
    }

    // Internal functions
    function incrementCount() internal {
        peopleCount ++;
    }
}