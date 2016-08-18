import "StandardMarketplace.sol";
import "Vehicle.sol";

contract DMR is StandardMarketplace{

	/* Vehicle mapping to license plates */
	mapping(uint => address) registerIndex;
	mapping(address => uint) register;

	uint counter = 0;
	uint importFee = 10000;

	function DMR(Token _token) StandardMarketplace(_token) {}

	/* issueing new car */
	function issueCar(bytes32 _vehicleId, address _importer) returns (address) {
		Vehicle car = new Vehicle(_vehicleId, this);
		car.sell(_importer, importFee);
		return car;
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
