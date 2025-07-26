// SPDX-License-Identifier: mit
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

    address public contractOwner;
    bool public paused;

    // --- Events ---
    event CreditListed(uint indexed id, address indexed owner, string creditType, uint amount, uint price);
    event CreditPurchased(uint indexed id, address indexed from, address indexed to, uint amount, uint total);
    event CreditDelisted(uint indexed id, address indexed owner);
    event CreditPriceUpdated(uint indexed id, uint oldPrice, uint newPrice);
    event CreditRelisted(uint indexed id, uint price);
    event CreditOwnershipTransferred(uint indexed id, address indexed from, address indexed to);
    event CreditAmountIncreased(uint indexed id, uint additionalAmount, uint newTotalAmount);
    event CreditTypeUpdated(uint indexed id, string oldType, string newType);
    event Paused();
    event Unpaused();

    // --- Modifiers ---
    modifier onlyCreditOwner(uint id) {
        require(credits[id].owner == msg.sender, "Not the owner");
        _;
    }

    modifier creditExists(uint id) {
        require(credits[id].id != 0, "Credit does not exist");
        _;
    }

    modifier onlyContractOwner() {
        require(msg.sender == contractOwner, "Not contract owner");
        _;
    }

    modifier whenNotPaused() {
        require(!paused, "Marketplace is paused");
        _;
    }

    // --- Constructor ---
    constructor() {
        contractOwner = msg.sender;
    }

    // --- Admin Functions ---
    function pause() external onlyContractOwner {
        paused = true;
        emit Paused();
    }

    function unpause() external onlyContractOwner {
        paused = false;
        emit Unpaused();
    }

    function withdraw() external onlyContractOwner {
        uint balance = address(this).balance;
        require(balance > 0, "No balance");
        payable(contractOwner).transfer(balance);
    }

    // --- Listing Functions ---
    function listCredit(string memory creditType, uint amount, uint pricePerUnit)
        external
        whenNotPaused
        returns (uint id)
    {
        require(amount > 0 && pricePerUnit > 0, "Invalid inputs");
        id = _createCredit(msg.sender, creditType, amount, pricePerUnit);
    }

    function batchListCredits(string[] calldata types, uint[] calldata amounts, uint[] calldata prices)
        external
        whenNotPaused
        returns (uint[] memory ids)
    {
        uint len = types.length;
        require(len > 0, "Empty input");
        require(len == amounts.length && len == prices.length, "Array mismatch");

        ids = new uint[](len);
        for (uint i = 0; i < len; i++) {
            require(amounts[i] > 0 && prices[i] > 0, "Invalid input");
            ids[i] = _createCredit(msg.sender, types[i], amounts[i], prices[i]);
        }
    }

    function relistCredit(uint id, uint newPrice)
        external
        creditExists(id)
        onlyCreditOwner(id)
    {
        require(newPrice > 0, "Invalid price");
        Credit storage c = credits[id];
        require(!c.isListed, "Already listed");
        require(c.amount > 0, "No credit left");

        c.pricePerUnit = newPrice;
        c.isListed = true;
        emit CreditRelisted(id, newPrice);
    }

    function delistCredit(uint id)
        external
        creditExists(id)
        onlyCreditOwner(id)
    {
        Credit storage c = credits[id];
        require(c.isListed, "Already delisted");

        c.isListed = false;
        emit CreditDelisted(id, msg.sender);
    }

    function updateCreditPrice(uint id, uint newPrice)
        external
        creditExists(id)
        onlyCreditOwner(id)
    {
        require(newPrice > 0, "Invalid price");

        Credit storage c = credits[id];
        require(c.isListed, "Not listed");

        uint oldPrice = c.pricePerUnit;
        c.pricePerUnit = newPrice;
        emit CreditPriceUpdated(id, oldPrice, newPrice);
    }

    // --- New Function: Update Credit Type ---
    function updateCreditType(uint id, string calldata newType)
        external
        creditExists(id)
        onlyCreditOwner(id)
    {
        require(bytes(newType).length > 0, "Invalid type");

        Credit storage c = credits[id];
        string memory oldType = c.creditType;
        c.creditType = newType;

        emit CreditTypeUpdated(id, oldType, newType);
    }

    // --- Purchase Function ---
    function purchaseCredit(uint id, uint amount)
        external
        payable
        whenNotPaused
        creditExists(id)
    {
        Credit storage c = credits[id];
        require(c.isListed, "Not listed");
        require(c.owner != msg.sender, "Self-purchase not allowed");
        require(c.amount >= amount, "Insufficient credits");

        uint totalCost = amount * c.pricePerUnit;
        require(msg.value >= totalCost, "Underpayment");

        address seller = c.owner;
        c.amount -= amount;

        if (c.amount == 0) {
            c.owner = msg.sender;
            c.isListed = false;
        }

        payable(seller).transfer(totalCost);
        if (msg.value > totalCost) {
            payable(msg.sender).transfer(msg.value - totalCost);
        }

        emit CreditPurchased(id, seller, msg.sender, amount, totalCost);
    }

    // --- Credit Management ---
    function transferOwnership(uint id, address to)
        external
        creditExists(id)
        onlyCreditOwner(id)
    {
        require(to != address(0) && to != msg.sender, "Invalid recipient");

        Credit storage c = credits[id];
        address from = c.owner;

        c.owner = to;
        c.isListed = false;

        emit CreditOwnershipTransferred(id, from, to);
    }

    function burnCredit(uint id, uint amount)
        external
        creditExists(id)
        onlyCreditOwner(id)
    {
        Credit storage c = credits[id];
        require(amount > 0 && c.amount >= amount, "Invalid burn amount");

        c.amount -= amount;
        if (c.amount == 0) c.isListed = false;
    }

    function increaseCreditAmount(uint id, uint addAmount)
        external
        creditExists(id)
        onlyCreditOwner(id)
        whenNotPaused
    {
        require(addAmount > 0, "Invalid amount");

        Credit storage c = credits[id];
        c.amount += addAmount;

        if (!c.isListed) {
            c.isListed = true;
            emit CreditRelisted(id, c.pricePerUnit);
        }

        emit CreditAmountIncreased(id, addAmount, c.amount);
    }

    // --- View Functions ---
    function getCredit(uint id)
        external
        view
        creditExists(id)
        returns (Credit memory)
    {
        return credits[id];
    }

    function getCreditSummary(uint id)
        external
        view
        creditExists(id)
        returns (string memory, address, uint, uint, bool)
    {
        Credit storage c = credits[id];
        return (c.creditType, c.owner, c.amount, c.pricePerUnit, c.isListed);
    }

    function getAllCreditIds() external view returns (uint[] memory ids) {
        uint total = nextCreditId - 1;
        ids = new uint[](total);
        for (uint i = 0; i < total; i++) {
            ids[i] = i + 1;
        }
    }

    function getCreditsByOwner(address owner) external view returns (uint[] memory) {
        return _filterCredits(false, owner, "");
    }

    function getListedCredits() external view returns (uint[] memory) {
        return _filterCredits(true, address(0), "");
    }

    function getCreditsByType(string memory type_) external view returns (uint[] memory) {
        return _filterCredits(false, address(0), type_);
    }

    function getCreditsByOwnerAndType(address owner, string memory type_) external view returns (uint[] memory) {
        return _filterCredits(false, owner, type_);
    }

    function getListedCreditDetails() external view returns (Credit[] memory) {
        uint[] memory ids = _filterCredits(true, address(0), "");
        Credit[] memory listed = new Credit[](ids.length);

        for (uint i = 0; i < ids.length; i++) {
            listed[i] = credits[ids[i]];
        }
        return listed;
    }

    function getOwnerCreditValue(address owner) external view returns (uint total) {
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

    // --- Internal Functions ---
    function _createCredit(address owner, string memory type_, uint amount, uint price)
        internal
        returns (uint id)
    {
        id = nextCreditId++;
        credits[id] = Credit(id, owner, type_, amount, price, true);
        emit CreditListed(id, owner, type_, amount, price);
    }

    function _filterCredits(bool onlyListed, address filterOwner, string memory filterType)
        internal
        view
        returns (uint[] memory result)
    {
        uint[] memory temp = new uint[](nextCreditId - 1);
        uint count = 0;

        bytes32 typeHash = keccak256(bytes(filterType));
        bool filterTypeSet = bytes(filterType).length > 0;

        for (uint i = 1; i < nextCreditId; i++) {
            Credit storage c = credits[i];

            if (
                (!onlyListed || c.isListed) &&
                (filterOwner == address(0) || c.owner == filterOwner) &&
                (!filterTypeSet || keccak256(bytes(c.creditType)) == typeHash)
            ) {
                temp[count++] = i;
            }
        }

        result = new uint[](count);
        for (uint j = 0; j < count; j++) {
            result[j] = temp[j];
        }
    }
}
