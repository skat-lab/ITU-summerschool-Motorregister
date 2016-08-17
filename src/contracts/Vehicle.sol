import "Tradeable.sol";
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


contract DMR is StandardMarketplace {

	/* Vehicle mapping to license plates */
	mapping(uint => address) registerIndex;
	mapping(address => uint) register;

	uint counter = 0;
	uint importFee = 10000;

	/* issueing new car */
	function issueCar(bytes32 _vehicleId, address _importer) {
		Vehicle car = new Vehicle(_vehicleId, this);
		car.sell(_importer, importFee);
	}

	function deregisterCar(Vehicle _vehicle){
		_vehicle.commitSuicide();
	}

	/* Registers the car */
	function completeTransaction(Tradeable _tradeable){
		var id = counter++;

		register[_tradeable] = id;
		registerIndex[id] = _tradeable;

		super.completeTransaction(_tradeable);
	}
}
