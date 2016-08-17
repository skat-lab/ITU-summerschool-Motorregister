contract Tradeable {

	/* Fields */
	address owner;
	address market;
	address buyer;

	/* Modifiers */
	modifier isOwner() { if(msg.sender != owner) throw; }
	modifier isMarket() { if(msg.sender != market) throw; }

	function allowTransfer(address _market, address _to) isOwner {
		market = _market;
		buyer = _to;
	}

	function transfer(address to) isMarket {
		owner = buyer;
		market = 0;
		buyer = 0;
	}
}

