contract Token {
	/* This is a slight change to the ERC20 base standard.
	   function totalSupply() constant returns (uint256 supply);
	   is replaced with:
	   uint256 public totalSupply;
	   This automatically creates a getter function for the totalSupply.
	   This is moved to the base contract since public getter functions are not
	   currently recognised as an implementation of the matching abstract
	   function by the compiler.
	 */
	/// total amount of tokens
	uint256 public totalSupply;

	/// @param _owner The address from which the balance will be retrieved
	/// @return The balance
	function balanceOf(address _owner) constant returns (uint256 balance);

	/// @notice send `_value` token to `_to` from `msg.sender`
	/// @param _to The address of the recipient
	/// @param _value The amount of token to be transferred
	/// @return Whether the transfer was successful or not
	function transfer(address _to, uint256 _value) returns (bool success);

	/// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
	/// @param _from The address of the sender
	/// @param _to The address of the recipient
	/// @param _value The amount of token to be transferred
	/// @return Whether the transfer was successful or not
	function transferFrom(address _from, address _to, uint256 _value) returns (bool success);

	/// @notice `msg.sender` approves `_addr` to spend `_value` tokens
	/// @param _spender The address of the account able to transfer the tokens
	/// @param _value The amount of wei to be approved for transfer
	/// @return Whether the approval was successful or not
	function approve(address _spender, uint256 _value) returns (bool success);

	/// @param _owner The address of the account owning tokens
	/// @param _spender The address of the account able to transfer the tokens
	/// @return Amount of remaining tokens allowed to spent
	function allowance(address _owner, address _spender) constant returns (uint256 remaining);

	event Transfer(address indexed _from, address indexed _to, uint256 _value);
	event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract Tradeable {
	function sell(address _buyer, uint _amount);
	function transferContract(address _to);
	function cancelSale();
}

contract StandardTradeable is Tradeable {

	/* Fields */
	address public owner;
	bool private forSale = false;
	Marketplace public market;

	/* Modifiers */
	modifier onlyBy(address _addr) {
		if(msg.sender != _addr) throw;
		else _
	}


	/* Constructor */
	function StandardTradeable(Marketplace _market){
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

contract Vehicle is StandardTradeable {

	bytes32 public vehicleId;

	function Vehicle(bytes32 _vehicleId, Marketplace _market) StandardTradeable(_market) {
		vehicleId = _vehicleId;
	}

	function setOwner(address _owner) onlyBy(market) {
		owner = _owner;
	}

	function commitSuicide() onlyBy(market) {
		selfdestruct(owner);
	}
}

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

contract StandardMarketplace is Marketplace {

	/* Fields */
	address private owner;
	Token public token;

	/* This is used for upgrading the marketplace */
	Marketplace private newest = Marketplace(0x0);

	/*  Mappings */
	mapping(address => Offer) public offers; //Vehicle to Offer mapping
	mapping(address => uint) balance;

	/* Events */
	event BuyerAcceptedOffer(Tradeable item);
	event SellerAddedOffer(Tradeable item);
	event SellerRevokedOffer(Tradeable item);
	event BuyerCompletedTransaction(Tradeable item);
	event BuyerAbortedTransaction(Tradeable item);

	/* Modifiers */

	//Checks that the item is the sender
	modifier onlyBy(address _addr){
		if(msg.sender != _addr) throw;
		else _
	}

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

	function acceptOffer(Tradeable _item) {

		/* Getting offer from item */
		var offer = offers[_item];
		if(offer.buyer != msg.sender) throw;

		/* Checking that the buyer have sufficient funds */
		if(token.allowance(msg.sender, this) < offer.amount) throw;

		/* Withdrawing money from buyers account */
		token.transferFrom(offer.buyer, this, offer.amount);
		balance[offer.buyer] += offer.amount;

		/* Notifiying seller about the buyer accepting the offer */
		BuyerAcceptedOffer(_item);
	}

	function completeTransaction(Tradeable _item) {

		/* Getting offer from item */
		var offer = offers[_item];
		if(offer.buyer != msg.sender) throw;
		if(balance[offer.buyer] < offer.amount) throw;

		/* Depositing amount to sellers account */
		token.transfer(offer.seller, offer.amount);
		balance[offer.buyer] -= offer.amount;

		/* Transfering the ownership to the buyer */
		_item.transferContract(offer.buyer);
		BuyerCompletedTransaction(_item);

		delete offers[_item];
	}

	function abortTransaction(Tradeable _item) {

		/* Getting offer from item */
		var offer = offers[_item];
		if(offer.buyer != msg.sender) throw;

		/* Depositing the amount back to the buyer */
		token.transfer(offer.buyer, offer.amount);

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

contract DMR is StandardMarketplace{

	/* Vehicle mapping to license plates */
	mapping(uint => address) public registerIndex;
	mapping(address => uint) public register;

	uint counter = 0;
	uint importFee = 0;

	function DMR(Token _token) StandardMarketplace(_token) {}

	/* issueing new car */
	function issueCar(bytes32 _vehicleId, address _importer) {
		Vehicle car = new Vehicle(_vehicleId, this);

		var id = counter++;
		registerIndex[id] = car;
		register[car] = id;

		car.setOwner(_importer);
	}

	function deregisterCar(Vehicle _vehicle){
		_vehicle.commitSuicide();
	}
}
