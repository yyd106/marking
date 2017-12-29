pragma solidity ^0.4.18;

contract MatchMaker{
    address minter;
    //mapping(address => funder) seekers;
    uint BigNumber;
    mapping (address => uint) public balances;

    struct MatchContract{
        address seekerMale;
        address seekerFemale;
        address delegateMale;
        address delegateFemale;
        uint amountMale;
        uint amountFemale;
        uint matchTime;
        uint completeTime;
        string status; // "Created" "Completed" "Canceled"
    }
    MatchContract[] public matchContracts;

    struct DelegateContract{
        address seeker;
        address delegate;
        uint advance;
        uint commission;
        string status; //  "Created" "Canceled" "Completed"
    }
    DelegateContract[] public delegateContracts;

    struct Delegate{
        //DelegateContract[] mySeekers;
        address myAddress;
        address[] mySeekers;
        mapping(address => uint) myDelegateContracts;
        mapping(address => uint) myMatchContracts;
        string status;
    }
    //Delegate[] delegates;
    mapping(address => Delegate)  public delegates;


    struct Seeker{
        address myAddress;
        uint commission;
        uint advance;
        string gender;
        address[] myDelegates;
        mapping(address => uint) myDelegateContracts;
        mapping(address => uint) myMatchContracts;
        string status;
    }
    mapping(address => Seeker) public seekers;

    function MatchMaker() public {
        minter = msg.sender;
        BigNumber = 9999999;
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
            seekers[seeker].myDelegates.push(delegate);
            delegates[delegate].mySeekers.push(seeker);
            delegateContracts.push(DelegateContract({seeker:seeker,
                    delegate:delegate,
                    advance:seekers[seeker].advance,
                    commission:seekers[seeker].commission,
                    status:"Created"}));
            uint delegateContractLocagtion;
            delegateContractLocagtion = delegateContracts.length - 1;
            seekers[seeker].myDelegateContracts[delegate] = delegateContractLocagtion;
            delegates[delegate].myDelegateContracts[seeker] = delegateContractLocagtion;
        }
    }

    function matchContract(address delegateMale, address delegateFemale, address seekerMale, address seekerFemale) public{
        uint location = getLocationInGlobalMatchArray(delegateMale, delegateFemale, seekerMale, seekerFemale);
        if(location != BigNumber){
            return;
        }
        else{
            matchContracts.push(MatchContract({seekerMale:seekerMale,
                      seekerFemale:seekerFemale,
                      delegateMale:delegateMale,
                      delegateFemale:delegateFemale,
                      amountMale:seekers[seekerMale].commission,
                      amountFemale:seekers[seekerFemale].commission,
                      matchTime: block.timestamp,
                      completeTime: 0,
                      status: "Created"}));
            uint matchContractLocation = matchContracts.length - 1;
            seekers[seekerMale].myMatchContracts[seekerFemale] = matchContractLocation;
            seekers[seekerFemale].myMatchContracts[seekerMale] = matchContractLocation;
            delegates[delegateMale].myMatchContracts[seekerFemale] = matchContractLocation;
            delegates[delegateFemale].myMatchContracts[seekerMale] = matchContractLocation;
        }
    }

    function completeMatch(address delegateMale, address delegateFemale, address seekerMale, address seekerFemale) public {
      uint location = getLocationInGlobalMatchArray(delegateMale, delegateFemale, seekerMale, seekerFemale);
      if(location == BigNumber){
          return;
      }
      else{
          matchContracts[location].status = "Completed";
          matchContracts[location].completeTime = block.timestamp;
          balances[delegateMale] += seekers[seekerMale].commission;
          balances[delegateFemale] += seekers[seekerFemale].commission;

      }
    }

    function cancelDelegateContract(address seeker, address delegate) private{
        uint index = getLocationInDelegateContractArray(seeker, delegate);
        if(index == BigNumber) return;
        delegateContracts[index].status = "Canceled";
        uint seekerIndex = getSeekerLocationInDelegateArray(seeker,delegate);
        uint delegateIndex = getDelegateLocationInSeekerArray(seeker, delegate);
        deleteAddressInArray(seekerIndex, seekers[seeker].myDelegates);   /// delete
        deleteAddressInArray(delegateIndex, delegates[delegate].mySeekers);  /// delete
    }

    function cancelMatchContract(address delegateMale, address delegateFemale, address seekerMale, address seekerFemale)public{
        uint index = getLocationInGlobalMatchArray(delegateMale,
            delegateFemale,
            seekerMale,
            seekerFemale);
        if(index == BigNumber) return;
        matchContracts[index].status = "Canceled";
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

    function deleteAddressInArray(uint index, address[] storage targetArray) private{
        if(index == BigNumber) return;
        for (uint i = index; i < targetArray.length; i++){
            targetArray[i] = targetArray[i+1];
        }
        delete targetArray[targetArray.length - 1];
    }

    function getLocationInDelegateContractArray(address seeker, address delegate) constant private returns (uint location){
      uint length = delegateContracts.length;
      for(uint i = 0; i < length; i++) {
          if (delegateContracts[i].delegate == delegate && delegateContracts[i].seeker == seeker) return i;
      }
      return BigNumber;
    }

    function getLocationInMatchArray(address delegateMale,
        address delegateFemale,
        address seekerMale,
        address seekerFemale)constant private returns (uint location) {
        uint length = matchContracts.length;
        for(uint i = 0; i < length; i++){
            if (matchContracts[i].seekerMale == seekerMale &&
                matchContracts[i].seekerFemale == seekerFemale &&
                matchContracts[i].delegateMale == delegateMale &&
                matchContracts[i].delegateFemale == delegateFemale)
                return i;
        }
        return BigNumber;
    }

    function getLocationInGlobalMatchArray(address delegateMale,
        address delegateFemale,
        address seekerMale,
        address seekerFemale)constant private returns (uint location) {
        uint length = matchContracts.length;
        for(uint i = 0; i < length; i++){
            if (matchContracts[i].seekerMale == seekerMale &&
                matchContracts[i].seekerFemale == seekerFemale &&
                matchContracts[i].delegateMale == delegateMale &&
                matchContracts[i].delegateFemale == delegateFemale)
                return i;
        }
        return BigNumber;
    }

    function getLocationInMatchArray(address delegateMale,
        address delegateFemale,
        address seekerMale,
        address seekerFemale,
        MatchContract[] matchArray)constant private returns (uint location) {
        uint length = matchArray.length;
        for(uint i = 0; i < length; i++){
            if (matchArray[i].seekerMale == seekerMale &&
                matchArray[i].seekerFemale == seekerFemale &&
                matchArray[i].delegateMale == delegateMale &&
                matchArray[i].delegateFemale == delegateFemale)
                return i;
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
        length = delegateContracts.length;
        return length;
    }

}
