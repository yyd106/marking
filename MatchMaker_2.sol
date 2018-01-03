pragma solidity ^0.4.18;

contract MatchMaker{
    address minter;
    //mapping(address => funder) seekers;
    uint BigNumber;
    mapping (address => uint) public balances;
    address[] newMatchContracts;
    address[] newDelegateContracts;
    struct Seeker{
        address myAddress;
        uint commission;
        uint advance;
        string gender;
        address[] myDelegates; // THis could be store in off-chain sever
        uint[] myDelegateContracts;
        uint[] myMatchContracts;
        string status;
    }
    mapping(address => Seeker) public seekers;

    struct Delegate{
        address myAddress;
        string status;  //"Active"  "Inactive"
        address[] mySeekers;
        uint[] myDelegateContracts;
        uint[] myMatchContracts;
    }
    mapping(address => Delegate) public delegates;

    function MatchMaker() public {
        minter = msg.sender;
        BigNumber = 999999999;
    }

    function initialSeeker(address seeker, string gender, uint commission, uint advance) public returns (string contractStatus)  {
        if(seekers[seeker].commission > 0){
            return "Already initialed";
            //return contractStatus;
         }
        else if(commission < advance){
            return "Commission must more than advance";
            //return contractStatus;
        }
        else {
            seekers[seeker].commission = commission;
            seekers[seeker].myAddress = seeker;
            seekers[seeker].gender = gender;
            seekers[seeker].advance = advance;
            seekers[seeker].status = "Active";
            // trigger a payment via wechat
            //send(seeker, minter, amount);
            return "Seeker Initianled!";
        }
    }

    function initialDelegate(address delegate) public returns (string contractStatus)  {
        if(keccak256(delegates[delegate].status) == keccak256("Active")) contractStatus = "Already initialed";
        else {
            delegates[delegate].myAddress = delegate;
            delegates[delegate].status = "Active";
            return "Delegate Initianled!";
        }
    }

    function confirmSeekerDelegate(address seeker, address delegate) public{
        uint seekerLocation = getSeekerLocationInDelegateArray(seeker, delegate);
        uint delegateLocation = getDelegateLocationInSeekerArray(seeker, delegate);
        if(seekerLocation != BigNumber && delegateLocation != BigNumber){
            return;
        }
        else{
            address newDeleContract = new DelegateContract(seeker, delegate, seekers[seeker].advance, seekers[seeker].commission);

            newDelegateContracts.push(newDeleContract);
            uint contractLocation = newDelegateContracts.length - 1;
            seekers[seeker].myDelegates.push(delegate);
            delegates[delegate].mySeekers.push(seeker);
            seekers[seeker].myDelegateContracts.push(contractLocation);
            delegates[delegate].myDelegateContracts.push(contractLocation);
        }
    }

    function matchContract(address delegateMale, address delegateFemale, address seekerMale, address seekerFemale) public{
        uint location = getLocationInGlobalMatchArray(seekerMale, seekerFemale);
        if(location != BigNumber){
            return;
        }
        else{
            address newMatchContract = new MatchContract(seekerMale, seekerFemale, delegateMale, delegateFemale, seekers[seekerMale].commission, seekers[seekerFemale].commission);
            newMatchContracts.push(newMatchContract);
            uint matchContractLocation = newMatchContracts.length - 1;
            seekers[seekerMale].myMatchContracts.push(matchContractLocation);
            seekers[seekerFemale].myMatchContracts.push(matchContractLocation);
            delegates[delegateMale].myMatchContracts.push(matchContractLocation);
            delegates[delegateFemale].myMatchContracts.push(matchContractLocation);
        }
    }

    function completeMatch(address delegateMale, address delegateFemale, address seekerMale, address seekerFemale) public {
      uint location = getLocationInGlobalMatchArray(seekerMale, seekerFemale);
      if(location == BigNumber){
          return;
      }
      else{
          MatchContract con = MatchContract(newMatchContracts[location]);
          con.completeContract();
          balances[delegateMale] += seekers[seekerMale].commission;
          balances[delegateFemale] += seekers[seekerFemale].commission;

      }
    }

    function cancelDelegateContract(address seeker, address delegate) private{
        uint index = getLocationInDelegateContractArray(seeker, delegate);
        if(index == BigNumber) return;
        DelegateContract con = DelegateContract(newDelegateContracts[index]);
        con.cancelContract();
        uint seekerIndex = getSeekerLocationInDelegateArray(seeker,delegate);
        uint delegateIndex = getDelegateLocationInSeekerArray(seeker, delegate);
        deleteAddressInArray(seekerIndex, seekers[seeker].myDelegates);   /// delete
        deleteAddressInArray(delegateIndex, delegates[delegate].mySeekers);  /// delete
    }

    function cancelMatchContract(address seekerMale, address seekerFemale)public{
        uint index = getLocationInGlobalMatchArray(seekerMale, seekerFemale);
        if(index == BigNumber) return;
        MatchContract con = MatchContract(newMatchContracts[index]);
        con.cancelContract();
    }

    function getSeekerLocationInDelegateArray(address seeker, address delegate) constant private returns (uint location) {
        uint length = seekers[seeker].myDelegates.length;
        for(uint i = 0; i < length; i++) {
            if (seekers[seeker].myDelegates[i] == delegate) return i;
        }
        return BigNumber;
    }

    function getDelegateLocationInSeekerArray(address seeker, address delegate) constant private returns (uint location) {
        uint length = delegates[delegate].mySeekers.length;
        for(uint i = 0; i < length; i++) {
            if (delegates[delegate].mySeekers[i] == seeker) return i;
        }
        return BigNumber;
    }

    function getLocationInDelegateContractArray(address seeker, address delegate) constant private returns (uint location) {
        uint length = newDelegateContracts.length;
        address seekerAddr;
        address delegateAddr;
        for(uint i = 0; i < length; i++){
            DelegateContract con =  DelegateContract(newDelegateContracts[i]);
            seekerAddr = con.getSeeker();
            delegateAddr = con.getDelegate();
            if(seeker == seekerAddr && delegate == delegateAddr){
                return i;
            }
        }
        return BigNumber;
    }

    function deleteAddressInArray(uint index, address[] storage targetArray) private{
        if(index == BigNumber) return;
        for (uint i = index; i < targetArray.length; i++){
            targetArray[i] = targetArray[i+1];
        }
        delete targetArray[targetArray.length - 1];
    }

    function getLocationInGlobalMatchArray(address seekerMale, address seekerFemale)constant private returns (uint location) {
        uint length = newMatchContracts.length;
        address SeekerMale;
        address SeekerFemale;
        for(uint i = 0; i < length; i++){
          MatchContract con =  MatchContract(newMatchContracts[i]);
          SeekerMale = con.getSeekerMale();
          SeekerFemale = con.getSeekerFemale();
            if (seekerMale == SeekerMale && seekerFemale == SeekerFemale){
                return i;
            }
        }
        return BigNumber;
    }


    function getLocationInMatchArray(address seekerMale, address seekerFemale)constant private returns (uint location) {
        uint length = seekers[seekerFemale].myMatchContracts.length;
        address matcher;
        for(uint i = 0; i < length; i++){
            MatchContract con =  MatchContract(seekers[seekerFemale].myMatchContracts[i]);
            matcher = con.getSeekerMale();
            if (matcher == seekerMale){
                return i;
            }
        }
        return BigNumber;
    }

    function send(address sender, address receiver, uint amount) public {
        if (balances[sender] < amount) return;
        balances[sender] -= amount;
        balances[receiver] += amount;
    }

    function mint(address receiver, uint amount) public {
        if (msg.sender != minter) return;
        balances[receiver] += amount;
    }

    function getDelegateArrayLength()public constant returns(uint length) {
        length = newDelegateContracts.length;
        return length;
    }
}

contract DelegateContract{
  address seeker;
  address delegate;
  uint advance;
  uint commission;
  string status; //  "Created" "Canceled" "Completed"

  function DelegateContract(address Seeker, address Delegate, uint Advance, uint Commission)public{
    seeker = Seeker;
    delegate = Delegate;
    advance = Advance;
    commission = Commission;
    status = "Created";

  }

  function cancelContract()public{
    status = "Canceled";
  }

  function getSeeker() public constant returns(address Seeker) {
    return seeker;
  }
  function getDelegate() public constant returns(address Delegate) {
    return delegate;
  }
  function getAdvance() public constant returns(uint Advance) {
    return advance;
  }
  function getCommission() public constant returns(uint Commission) {
    return commission;
  }

}

contract MatchContract{
  address seekerMale;
  address seekerFemale;
  address delegateMale;
  address delegateFemale;
  uint commissionMale;
  uint commissionFemale;
  uint matchTime;
  uint completeTime;
  string status; //  "Created" "Canceled" "Completed"
  uint BigNumber;

  function MatchContract(address SeekerMale, address SeekerFemale, address DelegateMale, address DelegateFemale, uint CommissionMale, uint CommissionFemale)public{
    BigNumber = 999999999;
    seekerMale = SeekerMale;
    seekerFemale = SeekerFemale;
    delegateMale = DelegateMale;
    delegateFemale = DelegateFemale;
    commissionMale = CommissionMale;
    commissionFemale = CommissionFemale;
    matchTime = block.timestamp;
    completeTime = BigNumber;
    status = "Created";
  }

  function completeContract() public {
    completeTime = block.timestamp;
    status = "Completed";
  }

  function cancelContract()public{
    status = "Canceled";
  }

  function getSeekerMale() public constant returns(address SeekerMale) {
    SeekerMale = seekerMale;
  }
  function getSeekerFemale() public constant returns(address SeekerFemale) {
    SeekerFemale = seekerFemale;
  }
  function getDelegates() public constant returns(address DelegateMale, address DelegateFemale) {
    DelegateMale = delegateMale;
    DelegateFemale = delegateFemale;
  }

  function getCommission() public constant returns(uint CommissionMale, uint CommissionFemale) {
    CommissionMale = commissionMale;
    CommissionFemale = commissionFemale;
  }

}
