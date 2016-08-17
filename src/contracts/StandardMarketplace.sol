import "Token.sol";
import "Tradeable.sol";
import "Marketplace.sol";

contract StandardMarketplace is Marketplace{

	/* Fields */
	address private owner;
	Token public token;

	/* This is used for upgrading the marketplace */
	Marketplace private newest = Marketplace(0x0);

	/*  Mappings */
	mapping(address => Offer) private offers; //Vehicle to Offer mapping

	/* Events */
	event BuyerAcceptedOffer(Tradeable item);
	event SellerAddedOffer(Tradeable item);
	event SellerRevokedOffer(Tradeable item);
	event BuyerCompletedTransaction(Tradeable item);
	event BuyerAbortedTransaction(Tradeable item);

	/* Modifiers */

	//Checks that the item is the sender
	modifier onlyBy(address _addr){ if(_addr == msg.sender) throw; }

	/* Constructor */
	function StandardMarketplace (Token _token){
		token = _token;
		owner = msg.sender;
	}

	function makeOffer(
		Tradeable _item,
		address _seller,
		address _buyer,
		uint _amount
	) onlyBy(_item) {

		offers[_item] = Offer({
			seller: _seller,
			buyer: _buyer,
			amount: _amount
		});

		SellerAddedOffer(_item);
	}

	function revokeOffer(Tradeable _item) onlyBy(_item) {
		SellerRevokedOffer(_item);
		delete offers[_item];
	}

	function acceptOffer(Tradeable _item) onlyBy(offers[_item].buyer) {

		/* Getting offer from item */
		var offer = offers[_item];

		/* Checking that the buyer have sufficient funds */
		if(token.allowance(msg.sender, this) < offer.amount) throw;

		/* Withdrawing money from buyers account */
		token.transferFrom(offer.buyer, this, offer.amount);

		/* Notifiying seller about the buyer accepting the offer */
		BuyerAcceptedOffer(_item);
	}

	function completeTransaction(Tradeable _item) onlyBy(offers[_item].buyer) {

		/* Getting offer from item */
		var offer = offers[_item];

		/* Depositing amount to sellers account */
		token.transferFrom(this, offer.seller, offer.amount);

		/* Transfering the ownership to the buyer */
		_item.transferContract(offer.buyer);
		BuyerCompletedTransaction(_item);

		delete offers[_item];
	}

	function abortTransaction(Tradeable _item) onlyBy(offers[_item].buyer) {

		/* Getting offer from item */
		var offer = offers[_item];

		/* Depositing the amount back to the buyer */
		token.transferFrom(this, offer.buyer, offer.amount);

		/* Revoking the markets rights to selling the item */
		_item.cancelSale();
		BuyerAbortedTransaction(_item);

		/* Deleting the offer */
		delete offers[_item];
	}

	function commitSuicide() onlyBy(owner) {
		selfdestruct(owner);
	}

	struct Offer {
		address seller;
		address buyer;
		uint amount;
	}
}

// vim: cc=80
