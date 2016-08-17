contract Vehicle {
	/* Fields */
	address private owner;
	uint public numPreviousOwners = 0;
	uint public serialNumber;

	/* Events */
	event OwnershipChanged(address newOwner);

	/* Mappings */
	mapping (uint => address) OwnerHistory;

	function Vehicle (uint _serialNumber) {
		owner = msg.sender;
		serialNumber = _serialNumber;
	}

	modifier isOwner () {
		if (msg.sender != owner) {
			throw;
		}
	}

	function transfer(address newOwner) isOwner {
		OwnerHistory[numPreviousOwners++] = owner;
		owner = newOwner;
		OwnershipChanged(newOwner);
	}

	function () {
		throw;
	}
}
