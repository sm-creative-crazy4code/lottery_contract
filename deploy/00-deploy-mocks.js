/**
 * we will only be deploying mocks only when we are on our development chain 
 * not incase of any test net
 */




const developmentChains= require ("../helper-hardhat-config")
const { deployments, network } = require("hardhat");



/**for each request the goerli network charges base fee of 0.25 link .it costas 0.25 link (oracle gas )per request
 * this is because each of the pricefeed is sponcered by a group of protocols that is paying for all these requests already
 * as we are only request for randomness we must be only one paying for it
*/
const BASE_FEE= ethers.utlis.parseEther("0.25")

/**calculated valueu based on the gas price of the chain
 * chainlink nodes pay the gas fee ang give us the randomness we request and do external execution
 * they get paid oracel gas to offset those costs but if the price of eth or any native chain sky rocketed then the chainlink will stop to pay the gas fee
 * and hence gas price link is a calculated variable which fluctuates according to the price of the actual chain so they dont get bankruppted
 * price of request changes based on the price of the gas of the blockchian
 * 
 */
const GAS_PRICE_LINK=1e9//link per gas

module.exports= async function ({ getNamedAccounts, deployments}){
const {deploy, logs}=deployments
const deployer = getNamedAccounts
const chainId= network.config.chainId
const args=[BASE_FEE,GAS_PRICE_LINK]

if(developmentChains.includes(network.name)){

    log("local network detected .... deploying mocks")
    // deploy the mock of vrf coordinator...

    const vrfCoordinatorv2 =await deploy("VRFCoordinatorV2Mock",{
     from: deployer,
     log:true,
     args:args
    })
    log("Mocks deployed")
    log("--------------------------------------------------------------------------------------------------------------------------------------")


}


}
module.exports.tags["all","mocks"]