/**
 * @dev Returns a list of credit IDs owned by a specific address
 * @param _owner Address to query credits for
 * @return ownerCreditIds Array of credit IDs owned by the address
 */
function getCreditsByOwner(address _owner) public view returns (uint[] memory ownerCreditIds) {
    uint totalCredits = nextCreditId - 1;
    uint count = 0;

    // Count how many credits are owned by _owner
    for (uint i = 1; i <= totalCredits; i++) {
        if (credits[i].owner == _owner) {
            count++;
        }
    }

    ownerCreditIds = new uint[](count);
    uint index = 0;

    // Collect all credit IDs owned by _owner
    for (uint i = 1; i <= totalCredits; i++) {
        if (credits[i].owner == _owner) {
            ownerCreditIds[index++] = i;
        }
    }
}
