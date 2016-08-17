contract Trader { function receiveOffer(address theContract, address _from, address _to, uint amount); }

contract Transferable {
  address owner;

  Trader transferAllowanceTrader;
  address transferAllowanceTo;

  modifier isOwner () {
    if (owner != msg.sender) throw;
  }

  modifier transferAllowed (address to) {
    if (transferAllowanceTrader != msg.sender
        || transferAllowanceTo != to) {
      throw;
    }
  }

  function getTrader() returns (address trader) {
    return address(transferAllowanceTrader);
  }

  function getTraderAllowanceTo() returns (address to) {
    return transferAllowanceTo;
  }
  
  function allowTransfer (address trader, address from, address to) isOwner {
    transferAllowanceTrader = Trader(trader);
    transferAllowanceTo = to;
  }

  function cancelTransfer () {
    transferAllowanceTrader = Trader(0x0);
    transferAllowanceTo = 0x0;
  }

  function transferContract (address to) transferAllowed(to) {
    owner = to;
  }
}
