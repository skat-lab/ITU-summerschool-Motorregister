import "StandardTradeable.sol";
import "StandardMarketplace.sol";

contract Vehicle is StandardTradeable {

	bytes32 vehicleId;

	function Vehicle(bytes32 _vehicleId, Marketplace _market) StandardTradeable(_market) {
		vehicleId = _vehicleId;
	}

	function setOwner(address _owner) onlyBy(market) {
		if(owner != 0x0) throw;	 //Only a new car can be transfered to an owner.
		owner = _owner;
	}

	function commitSuicide() onlyBy(market) {
		selfdestruct(owner);
	}
}
