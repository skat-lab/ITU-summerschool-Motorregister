import "Transferable.sol";

contract Vehicle is Transferable {
	/* Fields */
	uint public numPreviousOwners = 0;
	uint public serialNumber;

	/* Mappings */
	mapping (uint => address) OwnerHistory;

	function Vehicle (uint _serialNumber) {
		serialNumber = _serialNumber;

    // contructor of Transferable automatically called
	}

  function transferContract (address to) {
    OwnerHistory[numPreviousOwners++] = owner;
    Transferable.transferContract(to);
  }
}
