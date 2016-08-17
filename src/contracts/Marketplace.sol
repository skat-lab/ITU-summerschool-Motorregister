import "Tradeable.sol";

/* Token interface */
contract Token {
	function transfer(address reciever, uint amount);
	function transferFrom(
		address _from, 
		address _to, 
		uint256 _value
	) returns (bool success);

	function approveAndCall(
		address _spender,
		uint256 _value,
		bytes _extraData
	) returns (bool success);
}

/* Making the recipient able to be allowed to spent money on another behalf */
contract tokenRecipient {
	function receiveApproval(
		address _from,
		uint256 _value,
		address _token,
		bytes _extraData
	);
}

contract Marketplace is tokenRecipient {

	/* Fields */
	address private owner;
	Token public token;

	/*  Mappings */
	mapping(address => Offer) private offers; //Vehicle to Offer mapping
	mapping(address => uint) private balance; //Buyers balance

	/* Events */
	event BuyerAcceptedOffer(Tradeable item);

	/* Modifiers */
	
	//Checks that the item is the sender
	modifier isItem(Tradeable _item){ if(_item == msg.sender) throw; }

	//Checks that the owner of the marketsplace is the sender
	modifier isOwner() { if(msg.sender != owner) throw; }

	//Checks that the buyer of an item is the sender
	modifier isBuyer(Tradeable _item){
		if(offers[_item].buyer != msg.sender) throw;
	}

	//Checks that the seller of an item is the sender
	modifier isSeller(Tradeable _item) { 
		if(offers[_item].seller != msg.sender) throw; 
	}


	/* Constructor */
	function Marketplace (Token _token){
		token = _token;
		owner = msg.sender;
	}

	function makeOffer(Tradeable _item, address _seller, address _buyer, uint _amount) isItem(_item) {
		/* Adding offer to mapping of offers */ 
		offers[_item] = Offer({
			seller: _seller,
			buyer: _buyer,
			amount: _amount,
			allowedForWithdrawl: 0
		});
	}

	function revokeOffer(Tradeable _item) isSeller(_item) {
		_item.cancelSale();
		delete offers[_item];
	}

	function acceptOffer(Tradeable _item) isBuyer(_item) {

		/* Getting offer from item */
		var offer = offers[_item];

		/* Checking that the buyer have sufficient funds */
		if(balance[msg.sender] < offer.amount) throw;
		balance[offer.buyer] =- offer.amount;

		/* Withdrawing money from buyers account */
		token.transferFrom(offer.buyer, this, offer.amount);

		/* Notifiying seller about the buyer accepting the offer */
		BuyerAcceptedOffer(_item);
	}

	function completeTransaction(Tradeable _item) isBuyer(_item) {

		/* Getting offer from item */
		var offer = offers[_item];

		/* Depositing amount to sellers account */
		token.transferFrom(this, offer.seller, offer.amount);

		/* Transfering the ownership to the buyer */
		_item.transferContract(offer.buyer);

		delete offers[_item];
	}

	function abortTransaction(Tradeable _item) isBuyer(_item) {

		/* Getting offer from item */
		var offer = offers[_item];

		/* Depositing the amount back to the buyer */
		token.transferFrom(this, offer.buyer, offer.amount);

		/* Revoking the markets rights to selling the item */
		_item.cancelSale();

		/* Deleting the offer */
		delete offers[_item];
	}


	function receiveApproval(
		address _from,
		uint256 _value,
		address _token,
		bytes _extraData
	){
		/* Trades need to be in the marketsplace selected token */
		if(_token != address(token)) throw;

		/* Updates the buyers balance */
		balance[_from] = _value;
	}




	function commitSuicide() isOwner {
		selfdestruct(owner);
	}	
	
	struct Offer {
		address seller;
		address buyer;
		uint amount;
		uint allowedForWithdrawl;
	}
}

// vim: cc=80
