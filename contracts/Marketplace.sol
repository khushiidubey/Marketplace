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

    function listCredit(string memory _creditType, uint _amount, uint _price) external returns (uint id) {
        require(_amount > 0 && _price > 0, "Invalid amount or price");

        id = nextCreditId++;
        credits[id] = Credit(id, msg.sender, _creditType, _amount, _price, true);

        emit CreditListed(id, msg.sender, _creditType, _amount, _price);
    }

    function purchaseCredit(uint id, uint _amount) external payable creditExists(id) {
        Credit storage c = credits[id];

        require(c.isListed, "Credit not listed");
        require(c.owner != msg.sender, "Buyer cannot be owner");
        require(c.amount >= _amount, "Insufficient credit amount");

        uint total = _amount * c.pricePerUnit;
        require(msg.value >= total, "Insufficient payment");

        address seller = c.owner;

        // Transfer funds
        payable(seller).transfer(total);
        if (msg.value > total) {
            payable(msg.sender).transfer(msg.value - total); // Refund excess
        }

        // Update credit
        c.amount -= _amount;
        if (c.amount == 0) {
            c.owner = msg.sender;
            c.isListed = false;
        }

        emit CreditPurchased(id, seller, msg.sender, _amount, total);
    }

    function delistCredit(uint id) external onlyOwner(id) creditExists(id) {
        Credit storage c = credits[id];
        require(c.isListed, "Already delisted");

        c.isListed = false;
        emit CreditDelisted(id, msg.sender);
    }

    function updateCreditPrice(uint id, uint newPrice) external onlyOwner(id) creditExists(id) {
        Credit storage c = credits[id];
        require(c.isListed, "Not listed");
        require(newPrice > 0, "Invalid price");

        uint oldPrice = c.pricePerUnit;
        c.pricePerUnit = newPrice;

        emit CreditPriceUpdated(id, oldPrice, newPrice);
    }

    function relistCredit(uint id, uint price) external onlyOwner(id) creditExists(id) {
        Credit storage c = credits[id];
        require(!c.isListed, "Already listed");
        require(c.amount > 0 && price > 0, "Invalid relist params");

        c.pricePerUnit = price;
        c.isListed = true;

        emit CreditRelisted(id, price);
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
        require(additionalAmount > 0, "Amount must be greater than zero");

        Credit storage c = credits[id];
        c.amount += additionalAmount;

        // Optionally relist if it was previously delisted due to 0 amount
        if (!c.isListed) {
            c.isListed = true;
            emit CreditRelisted(id, c.pricePerUnit);
        }

        emit CreditAmountIncreased(id, additionalAmount, c.amount);
    }

    function getCreditDetails(uint id) external view creditExists(id) returns (Credit memory) {
        return credits[id];
    }

    function getListedCredits() external view returns (uint[] memory) {
        return filterCredits(true, address(0), "");
    }

    function getCreditsByOwner(address owner) external view returns (uint[] memory) {
        return filterCredits(false, owner, "");
    }

    function getCreditsByType(string memory creditType) external view returns (uint[] memory) {
        return filterCredits(false, address(0), creditType);
    }

    function getCreditsByOwnerAndType(address owner, string memory creditType) external view returns (uint[] memory) {
        return filterCredits(false, owner, creditType);
    }

    function getAllCredits() external view returns (uint[] memory ids) {
        uint count = nextCreditId - 1;
        ids = new uint[](count);
        for (uint i = 1; i <= count; i++) {
            ids[i - 1] = i;
        }
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

    // ✅ NEW FUNCTION: Lightweight summary of credit info
    function getCreditSummary(uint id) external view creditExists(id) returns (
        string memory creditType,
        address owner,
        uint amount,
        uint pricePerUnit,
        bool isListed
    ) {
        Credit storage c = credits[id];
        return (c.creditType, c.owner, c.amount, c.pricePerUnit, c.isListed);
    }

    // Internal utility function
    function filterCredits(bool byListed, address byOwner, string memory byType) internal view returns (uint[] memory result) {
        uint count;

        bytes32 typeHash = keccak256(bytes(byType));

        for (uint i = 1; i < nextCreditId; i++) {
            Credit storage c = credits[i];
            bool matchType = bytes(byType).length == 0 || keccak256(bytes(c.creditType)) == typeHash;
            bool matchOwner = byOwner == address(0) || c.owner == byOwner;
            bool matchListed = !byListed || c.isListed;

            if (matchListed && matchOwner && matchType) count++;
        }

        result = new uint[](count);
        uint idx = 0;

        for (uint i = 1; i < nextCreditId; i++) {
            Credit storage c = credits[i];
            bool matchType = bytes(byType).length == 0 || keccak256(bytes(c.creditType)) == typeHash;
            bool matchOwner = byOwner == address(0) || c.owner == byOwner;
            bool matchListed = !byListed || c.isListed;

            if (matchListed && matchOwner && matchType) {
                result[idx++] = i;
            }
        }
    }
}
