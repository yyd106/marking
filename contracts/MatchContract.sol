pragma solidity ^0.4.18;

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
