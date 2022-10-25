/** @type import('hardhat/config').HardhatUserConfig */
require("@nomiclabs/hardhat-waffle")
require("@nomiclabs/hardhat-etherscan")
require("hardhat-deploy")
require("solidity-coverage")
require("hardhat-gas-reporter")
require("hardhat-contract-sizer")
require("dotenv").config()


const GOERLI_URL= process.env.GOERLI_URL
const RINKEBY_URL= process.env.RINKEBY_URL
const PRIVATE_KEY= process.env.PRIVATE_KEY
const ETHERSCAN_API_KEY= process.env.ETHERSCAN_API_KEY
const COIN_MARKET_CAP_API_KEY= process.env.COIN_MARKET_CAP_API_KEY


module.exports = {
 defaultNetwork:"hardhat",
 networks:{
hardhat:{
  chainId:31337,
  blockConfirmations:1,
},
rinkeby:{
  chainId:4,
  blockConfirmations:1,
  url:RINKEBY_URL,
  accounts:[PRIVATE_KEY],
},
goreli:{
  chainId:57,
  blockConfirmations:3,
  url:GORELI_URL,
  accounts:[PRIVATE_KEY],
}
 },

  solidity: "0.8.7",

  namedAccounts:{
    deployer:{
      default:0,
    },
    players:{
      default:1,
    },
  }
};
