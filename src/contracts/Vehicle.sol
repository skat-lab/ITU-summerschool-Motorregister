contract Vehicle {
  address private owner;
  mapping (uint => address) owner_history;
  uint num_previous_owners;

  function Vehicle () {
    owner = msg.sender;
  }

  modifier isOwner () {
    if (msg.sender != owner) {
      throw;
    }
  }
  
  function transfer() {
    
  }
  
  function () {
    throw;
  }

}
