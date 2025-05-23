// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/**
 * @title CreditMarketplace
 * @dev Contract for listing, buying and trading credits
 */
contract CreditMarketplace {
    // Credit structure
    struct Credit {
        uint id;
        address owner;
        string creditType; // e.g. "Carbon", "Renewable Energy", etc.
        uint amount;
        uint pricePerUnit;
        bool isListed;
    }

    // Credit ID counter
    uint private nextCreditId = 1;

    // Mapping from credit ID to Credit
    mapping(uint => Credit) public credits;

    // Events
    event CreditListed(
        uint indexed creditId,
        address indexed owner,
        string creditType,
        uint amount,
        uint pricePerUnit
    );
    event CreditPurchased(
        uint indexed creditId,
        address indexed oldOwner,
        address indexed newOwner,
        uint amount,
        uint totalPrice
    );
    event CreditDelisted(uint indexed creditId, address indexed owner);
    event CreditPriceUpdated(uint indexed creditId, uint oldPrice, uint newPrice);

    /**
     * @dev Lists a new credit on the marketplace
     */
    function listCredit(
        string memory _creditType,
        uint _amount,
        uint _pricePerUnit
    ) public returns (uint) {
        require(_amount > 0, "Amount must be greater than zero");
        require(_pricePerUnit > 0, "Price must be greater than zero");

        uint creditId = nextCreditId++;

        credits[creditId] = Credit({
            id: creditId,
            owner: msg.sender,
            creditType: _creditType,
            amount: _amount,
            pricePerUnit: _pricePerUnit,
            isListed: true
        });

        emit CreditListed(creditId, msg.sender, _creditType, _amount, _pricePerUnit);

        return creditId;
    }

    /**
     * @dev Purchases credits from the marketplace
     */
    function purchaseCredit(uint _creditId, uint _amount) public payable {
        Credit storage credit = credits[_creditId];

        require(credit.isListed, "Credit is not listed for sale");
        require(credit.owner != msg.sender, "You cannot buy your own credits");
        require(credit.amount >= _amount, "Not enough credits available");

        uint totalPrice = _amount * credit.pricePerUnit;
        require(msg.value >= totalPrice, "Insufficient payment");

        address payable seller = payable(credit.owner);

        // Update credit amount or remove if all purchased
        if (credit.amount == _amount) {
            credit.isListed = false;
        }
        credit.amount -= _amount;

        // Transfer ownership if all credits are bought
        if (credit.amount == 0) {
            credit.owner = msg.sender;
        }

        // Send payment to seller
        seller.transfer(totalPrice);

        // Refund excess payment
        if (msg.value > totalPrice) {
            payable(msg.sender).transfer(msg.value - totalPrice);
        }

        emit CreditPurchased(_creditId, seller, msg.sender, _amount, totalPrice);
    }

    /**
     * @dev Removes a credit listing from the marketplace
     */
    function delistCredit(uint _creditId) public {
        Credit storage credit = credits[_creditId];

        require(credit.owner == msg.sender, "Only owner can delist credits");
        require(credit.isListed, "Credit is not listed");

        credit.isListed = false;

        emit CreditDelisted(_creditId, msg.sender);
    }

    /**
     * @dev Updates the price per unit for a listed credit
     */
    function updateCreditPrice(uint _creditId, uint _newPricePerUnit) public {
        Credit storage credit = credits[_creditId];

        require(credit.owner == msg.sender, "Only the credit owner can update the price");
        require(credit.isListed, "Credit must be listed to update price");
        require(_newPricePerUnit > 0, "Price must be greater than zero");

        uint oldPrice = credit.pricePerUnit;
        credit.pricePerUnit = _newPricePerUnit;

        emit CreditPriceUpdated(_creditId, oldPrice, _newPricePerUnit);
    }

    /**
     * @dev Gets details of a specific credit
     */
    function getCreditDetails(uint _creditId)
        public
        view
        returns (
            uint id,
            address owner,
            string memory creditType,
            uint amount,
            uint pricePerUnit,
            bool isListed
        )
    {
        Credit storage credit = credits[_creditId];
        return (
            credit.id,
            credit.owner,
            credit.creditType,
            credit.amount,
            credit.pricePerUnit,
            credit.isListed
        );
    }

    /**
     * @dev Returns a list of all currently listed credit IDs
     */
    function getListedCredits() public view returns (uint[] memory listedCreditIds) {
        uint totalCredits = nextCreditId - 1;
        uint count = 0;

        for (uint i = 1; i <= totalCredits; i++) {
            if (credits[i].isListed) {
                count++;
            }
        }

        listedCreditIds = new uint[](count);
        uint index = 0;

        for (uint i = 1; i <= totalCredits; i++) {
            if (credits[i].isListed) {
                listedCreditIds[index++] = i;
            }
        }
    }

    /**
     * @dev Returns credit IDs owned by a specific address
     */
    function getCreditsByOwner(address _owner) public view returns (uint[] memory ownedCredits) {
        uint totalCredits = nextCreditId - 1;
        uint count = 0;

        for (uint i = 1; i <= totalCredits; i++) {
            if (credits[i].owner == _owner) {
                count++;
            }
        }

        ownedCredits = new uint[](count);
        uint index = 0;

        for (uint i = 1; i <= totalCredits; i++) {
            if (credits[i].owner == _owner) {
                ownedCredits[index++] = i;
            }
        }
    }
}
