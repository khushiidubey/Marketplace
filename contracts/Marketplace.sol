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
    mapping(uint => Credit) private credits;

    event CreditListed(uint indexed id, address indexed owner, string creditType, uint amount, uint price);
    event CreditPurchased(uint indexed id, address indexed from, address indexed to, uint amount, uint total);
    event CreditDelisted(uint indexed id, address indexed owner);
    event CreditPriceUpdated(uint indexed id, uint oldPrice, uint newPrice);
    event CreditRelisted(uint indexed id, uint price);
    event CreditOwnershipTransferred(uint indexed id, address indexed from, address indexed to);
    event CreditAmountIncreased(uint indexed id, uint additionalAmount, uint newTotalAmount);

    modifier onlyOwner(uint id) {
        require(credits[id].owner == msg.sender, "Not the owner");
        _;
    }

    modifier creditExists(uint id) {
        require(credits[id].id != 0, "Credit does not exist");
        _;
    }

    function listCredit(string memory creditType, uint amount, uint pricePerUnit) external returns (uint id) {
        require(amount > 0 && pricePerUnit > 0, "Invalid amount or price");

        id = nextCreditId++;
        credits[id] = Credit(id, msg.sender, creditType, amount, pricePerUnit, true);

        emit CreditListed(id, msg.sender, creditType, amount, pricePerUnit);
    }

    function batchListCredits(string[] memory creditTypes, uint[] memory amounts, uint[] memory prices)
        external
        returns (uint[] memory ids)
    {
        uint count = creditTypes.length;
        require(count > 0, "Empty input");
        require(count == amounts.length && count == prices.length, "Array lengths mismatch");

        ids = new uint[](count);

        for (uint i = 0; i < count; i++) {
            require(amounts[i] > 0 && prices[i] > 0, "Invalid amount or price");

            uint id = nextCreditId++;
            credits[id] = Credit(id, msg.sender, creditTypes[i], amounts[i], prices[i], true);
            ids[i] = id;

            emit CreditListed(id, msg.sender, creditTypes[i], amounts[i], prices[i]);
        }
    }

    function purchaseCredit(uint id, uint amount) external payable creditExists(id) {
        Credit storage c = credits[id];

        require(c.isListed, "Credit not listed");
        require(c.owner != msg.sender, "Buyer cannot be owner");
        require(c.amount >= amount, "Insufficient credit amount");

        uint totalPrice = amount * c.pricePerUnit;
        require(msg.value >= totalPrice, "Insufficient payment");

        address seller = c.owner;
        c.amount -= amount;

        if (c.amount == 0) {
            c.owner = msg.sender;
            c.isListed = false;
        }

        payable(seller).transfer(totalPrice);

        if (msg.value > totalPrice) {
            payable(msg.sender).transfer(msg.value - totalPrice);
        }

        emit CreditPurchased(id, seller, msg.sender, amount, totalPrice);
    }

    function delistCredit(uint id) external onlyOwner(id) creditExists(id) {
        Credit storage c = credits[id];
        require(c.isListed, "Already delisted");

        c.isListed = false;
        emit CreditDelisted(id, msg.sender);
    }

    function updateCreditPrice(uint id, uint newPrice) external onlyOwner(id) creditExists(id) {
        require(newPrice > 0, "Invalid price");

        Credit storage c = credits[id];
        require(c.isListed, "Credit not listed");

        uint oldPrice = c.pricePerUnit;
        c.pricePerUnit = newPrice;

        emit CreditPriceUpdated(id, oldPrice, newPrice);
    }

    function relistCredit(uint id, uint newPrice) external onlyOwner(id) creditExists(id) {
        require(newPrice > 0, "Invalid price");

        Credit storage c = credits[id];
        require(!c.isListed, "Already listed");
        require(c.amount > 0, "No credit left to list");

        c.pricePerUnit = newPrice;
        c.isListed = true;

        emit CreditRelisted(id, newPrice);
    }

    function transferCreditOwnership(uint id, address to) external onlyOwner(id) creditExists(id) {
        require(to != address(0) && to != msg.sender, "Invalid recipient");

        Credit storage c = credits[id];
        address from = c.owner;

        c.owner = to;
        c.isListed = false;

        emit CreditOwnershipTransferred(id, from, to);
    }

    function burnCredit(uint id, uint amount) external onlyOwner(id) creditExists(id) {
        Credit storage c = credits[id];
        require(amount > 0 && c.amount >= amount, "Invalid burn amount");

        c.amount -= amount;
        if (c.amount == 0) c.isListed = false;
    }

    function increaseCreditAmount(uint id, uint additionalAmount) external onlyOwner(id) creditExists(id) {
        require(additionalAmount > 0, "Amount must be > 0");

        Credit storage c = credits[id];
        c.amount += additionalAmount;

        if (!c.isListed) {
            c.isListed = true;
            emit CreditRelisted(id, c.pricePerUnit);
        }

        emit CreditAmountIncreased(id, additionalAmount, c.amount);
    }

    function getCreditDetails(uint id) external view creditExists(id) returns (Credit memory) {
        return credits[id];
    }

    function getCreditSummary(uint id) external view creditExists(id)
        returns (string memory, address, uint, uint, bool)
    {
        Credit storage c = credits[id];
        return (c.creditType, c.owner, c.amount, c.pricePerUnit, c.isListed);
    }

    function getAllCredits() external view returns (uint[] memory ids) {
        uint count = nextCreditId - 1;
        ids = new uint[](count);
        for (uint i = 1; i <= count; i++) {
            ids[i - 1] = i;
        }
    }

    function getCreditsByOwner(address owner) external view returns (uint[] memory) {
        return filterCredits(false, owner, "");
    }

    function getListedCredits() external view returns (uint[] memory) {
        return filterCredits(true, address(0), "");
    }

    function getCreditsByType(string memory creditType) external view returns (uint[] memory) {
        return filterCredits(false, address(0), creditType);
    }

    function getCreditsByOwnerAndType(address owner, string memory creditType) external view returns (uint[] memory) {
        return filterCredits(false, owner, creditType);
    }

    function getTotalValueOfCreditsByOwner(address owner) external view returns (uint total) {
        for (uint i = 1; i < nextCreditId; i++) {
            Credit storage c = credits[i];
            if (c.owner == owner) {
                total += c.amount * c.pricePerUnit;
            }
        }
    }

    function getTotalListedValue() external view returns (uint total) {
        for (uint i = 1; i < nextCreditId; i++) {
            Credit storage c = credits[i];
            if (c.isListed) {
                total += c.amount * c.pricePerUnit;
            }
        }
    }

    function filterCredits(
        bool onlyListed,
        address filterOwner,
        string memory filterType
    ) internal view returns (uint[] memory result) {
        uint tempCount;
        bytes32 typeHash = keccak256(bytes(filterType));
        bool filterByType = bytes(filterType).length > 0;

        for (uint i = 1; i < nextCreditId; i++) {
            Credit storage c = credits[i];
            if (_matchFilters(c, onlyListed, filterOwner, typeHash, filterByType)) {
                tempCount++;
            }
        }

        result = new uint[](tempCount);
        uint idx;

        for (uint i = 1; i < nextCreditId; i++) {
            Credit storage c = credits[i];
            if (_matchFilters(c, onlyListed, filterOwner, typeHash, filterByType)) {
                result[idx++] = i;
            }
        }
    }

    function _matchFilters(
        Credit storage c,
        bool onlyListed,
        address filterOwner,
        bytes32 typeHash,
        bool filterByType
    ) private view returns (bool) {
        bool matchListed = !onlyListed || c.isListed;
        bool matchOwner = filterOwner == address(0) || c.owner == filterOwner;
        bool matchType = !filterByType || keccak256(bytes(c.creditType)) == typeHash;

        return matchListed && matchOwner && matchType;
    }
}
