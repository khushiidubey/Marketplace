// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract CreditMarketplace {
    struct Credit {
        uint id;
        address owner;
        string creditType;
        uint amount;
        uint pricePerUnit;
        bool isListed;
    }

    uint private nextCreditId = 1;
    mapping(uint => Credit) public credits;

    event CreditListed(uint indexed id, address indexed owner, string creditType, uint amount, uint price);
    event CreditPurchased(uint indexed id, address indexed from, address indexed to, uint amount, uint total);
    event CreditDelisted(uint indexed id, address indexed owner);
    event CreditPriceUpdated(uint indexed id, uint oldPrice, uint newPrice);
    event CreditRelisted(uint indexed id, uint price);
    event CreditOwnershipTransferred(uint indexed id, address indexed from, address indexed to);

    function listCredit(string memory _type, uint _amt, uint _price) public returns (uint id) {
        require(_amt > 0 && _price > 0, "Invalid amount or price");
        id = nextCreditId++;
        credits[id] = Credit(id, msg.sender, _type, _amt, _price, true);
        emit CreditListed(id, msg.sender, _type, _amt, _price);
    }

    function purchaseCredit(uint id, uint _amt) public payable {
        Credit storage c = credits[id];
        require(c.isListed && c.owner != msg.sender && c.amount >= _amt, "Invalid purchase");

        uint total = _amt * c.pricePerUnit;
        require(msg.value >= total, "Insufficient funds");

        payable(c.owner).transfer(total);
        if (msg.value > total) payable(msg.sender).transfer(msg.value - total);

        if (c.amount == _amt) c.isListed = false;
        c.amount -= _amt;
        if (c.amount == 0) c.owner = msg.sender;

        emit CreditPurchased(id, c.owner, msg.sender, _amt, total);
    }

    function delistCredit(uint id) public {
        Credit storage c = credits[id];
        require(c.owner == msg.sender && c.isListed, "Unauthorized or already delisted");
        c.isListed = false;
        emit CreditDelisted(id, msg.sender);
    }

    function updateCreditPrice(uint id, uint newPrice) public {
        Credit storage c = credits[id];
        require(c.owner == msg.sender && c.isListed && newPrice > 0, "Invalid update");
        emit CreditPriceUpdated(id, c.pricePerUnit, newPrice);
        c.pricePerUnit = newPrice;
    }

    function relistCredit(uint id, uint price) public {
        Credit storage c = credits[id];
        require(c.owner == msg.sender && !c.isListed && c.amount > 0 && price > 0, "Invalid relist");
        c.pricePerUnit = price;
        c.isListed = true;
        emit CreditRelisted(id, price);
    }

    function transferCreditOwnership(uint id, address to) public {
        Credit storage c = credits[id];
        require(c.owner == msg.sender && to != address(0) && to != msg.sender, "Invalid transfer");
        emit CreditOwnershipTransferred(id, c.owner, to);
        c.owner = to;
        c.isListed = false;
    }

    function burnCredit(uint id, uint amt) public {
        Credit storage c = credits[id];
        require(c.owner == msg.sender && amt > 0 && c.amount >= amt, "Invalid burn");
        c.amount -= amt;
        if (c.amount == 0) c.isListed = false;
    }

    function getCreditDetails(uint id) public view returns (Credit memory) {
        return credits[id];
    }

    function getListedCredits() public view returns (uint[] memory ids) {
        return filterCredits(true, address(0));
    }

    function getCreditsByOwner(address owner) public view returns (uint[] memory ids) {
        return filterCredits(false, owner);
    }

    function getTotalValueOfCreditsByOwner(address owner) public view returns (uint total) {
        for (uint i = 1; i < nextCreditId; i++) {
            if (credits[i].owner == owner) total += credits[i].amount * credits[i].pricePerUnit;
        }
    }

    function getTotalListedValue() public view returns (uint total) {
        for (uint i = 1; i < nextCreditId; i++) {
            if (credits[i].isListed) total += credits[i].amount * credits[i].pricePerUnit;
        }
    }

    function filterCredits(bool byListed, address byOwner) internal view returns (uint[] memory result) {
        uint count;
        for (uint i = 1; i < nextCreditId; i++) {
            if ((byListed && credits[i].isListed) || (!byListed && credits[i].owner == byOwner)) count++;
        }

        result = new uint[](count);
        uint idx = 0;
        for (uint i = 1; i < nextCreditId; i++) {
            if ((byListed && credits[i].isListed) || (!byListed && credits[i].owner == byOwner)) {
                result[idx++] = i;
            }
        }
    }

    function getAllCredits() public view returns (uint[] memory ids) {
        uint count = nextCreditId - 1;
        ids = new uint[](count);
        for (uint i = 1; i <= count; i++) {
            ids[i - 1] = i;
        }
    }

    // ✅ New Function: Get all credits by credit type
    function getCreditsByType(string memory creditType) public view returns (uint[] memory) {
        uint count;
        for (uint i = 1; i < nextCreditId; i++) {
            if (keccak256(bytes(credits[i].creditType)) == keccak256(bytes(creditType))) {
                count++;
            }
        }

        uint[] memory result = new uint[](count);
        uint index = 0;
        for (uint i = 1; i < nextCreditId; i++) {
            if (keccak256(bytes(credits[i].creditType)) == keccak256(bytes(creditType))) {
                result[index++] = i;
            }
        }
        return result;
    }
}
