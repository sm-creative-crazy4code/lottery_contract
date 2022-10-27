const { deployments, network } = require("hardhat")
const {developmentChains,developmentChains, networkConfig}= require ("../helper-hardhat-config")

module.exports= async function({getNamedAccounts,deplonments}){

const {deploy,logs}=deployments
const {deployer}=await getNamedAccounts()
let vrfCoordinatorAddress
const chainId= network.config.chainId

/**checking for local network */
if(developmentChains.includes(network.name)){
   const vrfCoordinatorV2Mock= await deploy("VRFCoordinatorV2Mock")
   vrfCoordinatorAddress= vrfCoordinatorV2Mock.address

}else{
    vrfCoordinatorAddress=networkConfig[chainId]['vrfCoordinatorV2']
}
const entranceFee=networkConfig[chainId]["entranceFee"]
const args=[]

const raffle= await deploy("Raffle",{
    from:deployer,
    args:args,
    log:true,
    waitConfirmations:network.config.blockConfirmations || 1,

})
}