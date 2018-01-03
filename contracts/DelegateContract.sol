pragma solidity ^0.4.18;


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
