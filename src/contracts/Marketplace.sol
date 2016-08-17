import "Tradeable.sol";

contract Marketplace {
	function makeOffer(Tradeable _item,	address _seller, address _buyer, uint _amount);	
	function revokeOffer(Tradeable _item);
	function acceptOffer(Tradeable _item);
	function completeTransaction(Tradeable _item);
	function abortTransaction(Tradeable _item);
	event BuyerAcceptedOffer(Tradeable item);
	event SellerAddedOffer(Tradeable item);
	event SellerRevokedOffer(Tradeable item);
	event BuyerCompletedTransaction(Tradeable item);
	event BuyerAbortedTransaction(Tradeable item);
}

// vim: cc=80
