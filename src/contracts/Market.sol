import "Token.sol";
import "Transferable.sol";

contract Market {
  Token currency;

  struct Offer {
    address seller;
    address buyer;
    Transferable theContract;
    uint amount;
    bool buyerAccepted;
  }
  
  mapping (address => Offer) offers;
  
  function Market(Token _currency) {
    currency = Token(_currency);
  }

  function makeOffer(Transferable theContract,
                     address seller,
                     address buyer,
                     uint amount) {
    Transferable c = Transferable(theContract);

    // You need to allow the market to perform a transfer before
    // making an offer
    if(c.getTrader() != address(this) || c.getTraderAllowanceTo() != buyer) {
      throw;
    }
   
    var o = Offer(seller, buyer, c, amount, false);
    offers[c] = o;
  }

  // Buyer approves, and funds are transfered on hold at the Market
  function receiveApproval(address _from, uint256 _value,
                           address _token, address theContract) {
    if(_token != address(currency)) throw;
    if(msg.sender != address(currency)) throw;
    
    Transferable c = Transferable(theContract);
    Offer offer = offers[c];
    if (_from != offer.buyer) throw;
    if (_value < offer.amount) throw;

    currency.transferFrom(offer.buyer, this, offer.amount);
    offer.buyerAccepted = true;
  }

  // Buyer approves that the goods are received
  function completeTransaction(Transferable theContract) isBuyer(theContract) {
    Offer offer = offers[theContract];
    if (!offer.buyerAccepted || msg.sender != offer.buyer) {
      throw;
    }

    // Transfer the contract
    theContract.transferContract(offer.buyer);
    
    // Transfer funds
    currency.transferFrom(this, offer.seller, offer.amount);

    delete offers[theContract];
  }

  // Buyer discards the transaction, and receives the money back
  function abortTransaction(Transferable theContract) isBuyer(theContract) {
    // We do 2 look-ups to the same contract, as we also lookup in isBuyer
    // - inefficient!
    Offer offer = offers[theContract];
    currency.transferFrom(this, offer.buyer, offer.amount);
    theContract.cancelTransfer();

    delete offers[theContract];
  }

  modifier isBuyer(Transferable theContract) {
    if (msg.sender != offers[theContract].buyer) throw;
  }

  modifier isSeller(Transferable theContract) {
    if (msg.sender != offers[theContract].buyer) throw;
  }
}
