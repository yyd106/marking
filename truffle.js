var Web3 = require('web3');
//var provider = new Web3.providers.HttpProvider("http:192.168.10.100:8545");
module.exports = {
  networks: {
    nodeth: {
      //provider: provider,
      network_id: 1006, // any network associated with your node
      host:'127.0.0.1',
      port:8822,
      gas: 400000000,
      //from: "0x6875483cd851990ddfcd5fd49f6732d71cbedb46"
      from:"0x2dc58c3b7617f44e301d7abb206579536ace9ca8"
    }
  }
};
