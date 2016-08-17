import "Marketplace.sol";

contract Tradeable {

	/* Fields */
	address public owner;
	bool private forSale = false;
	Marketplace private market;

	/* Modifiers */
	modifier onlyBy(address _addr) { if(msg.sender != _addr) throw; }
	modifier eitherBy(address _addr1, address _addr2) {
		if(msg.sender != _addr1 && msg.sender != _addr2) throw; 
	}

	/* Constructor */
	function Tradeable(Marketplace _market){
		owner = msg.sender;
		market = _market; //The tradeable is born with a given market
	}

	function sell(address _buyer, uint _amount) onlyBy(owner) {
		if(forSale) throw; //Cannot be set for sale if it's already for sale..
		market.makeOffer(this, owner, _buyer, _amount);
		forSale = true;
	}

	function cancelSale() onlyBy(owner) {
		if(!forSale) throw;
		market.revokeOffer(this);
		forSale = false;
	}

	function transferContract(address to) onlyBy(market) {
		owner = to;
	}

	function () {
		throw;
	}
}

// vim: cc=80
