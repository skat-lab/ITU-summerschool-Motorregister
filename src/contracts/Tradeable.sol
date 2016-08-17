import "Marketplace.sol";

contract Tradeable {

	/* Fields */
	address public owner;
	address market;

	/* Modifiers */
	modifier isOwner() { if(msg.sender != owner) throw; }
	modifier isMarket() { if(msg.sender != market) throw; }

	function sell(Marketplace _market, address _buyer, uint _amount) isOwner {
		_market.makeOffer(this, owner, _buyer, _amount);
		market = _market;
	}

	function transferContract(address to) isMarket {
		owner = to;
		market = 0;
	}

	function cancelSale() isMarket {
		market = 0;
	}

	function () {
		throw;
	}
}

