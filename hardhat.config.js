require("@nomiclabs/hardhat-waffle");
require("hardhat-deploy");
require("dotenv").config();
/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: {
    compilers: [{ version: "0.8.7" }, { version: "0.7.0" }],
  },
  namedAccounts: {
    deployer: {
      default: 0,
    },
  },
  networks: {
    hardhat: {
      chainId: 31337,
    },
    rinkeby: {
      url: process.env.RINKEBY_RPC_URL,
      accounts: [process.env.PRIVATE_KEY],
      chainId: 4,
    },
  },
};
