var Web3 = require('web3');
//var provider = new Web3.providers.HttpProvider("http:192.168.10.100:8545");
module.exports = {
  networks: {
    "nodeth": {
      //provider: provider,
      network_id: 201804, // any network associated with your node
      host:'127.0.0.1',
      port:8101,
      gas: 0x90000000,
      //from: "0x6875483cd851990ddfcd5fd49f6732d71cbedb46"
      from:"0x56766019b51ba5927c1e084e49ac0b26778b6f00"
    }
  }
};
