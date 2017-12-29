var MatchMaker = artifacts.require("./MatchMaker.sol");


module.exports = function(deployer) {
  deployer.deploy(MatchMaker);
};
