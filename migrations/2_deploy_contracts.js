var MatchMaker = artifacts.require("./MatchMaker");
var MatchContract = artifacts.require("./MatchContract");
var DelegateContract = artifacts.require("./DelegateContract");

module.exports = function(deployer) {
  var matchContract;
  var delegateContract;
  deployer.deploy(MatchContract)
  .then(function(instance){
    //matchContract = instance;
    deployer.deploy(DelegateContract)
    .then(function(instance){
//      delegateContract = instance;
      deployer.deploy(MatchMaker);
    })
  })
};

//module.exports = function(deployer) {
//  deployer.deploy(DelegateContract);
//};
