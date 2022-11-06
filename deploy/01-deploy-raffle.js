const {deployments, network, ethers } = require("hardhat")
const {developmentChains,networkConfig}= require ("../helper-hardhat-config")
const {verify}=require("../helper-hardhat-config")

const VRF_SUB_FUND_AMOUNT=  ethers.utils.parseEther('1')
module.exports= async function({getNamedAccounts,deployments}){

const {deploy,logs}=deployments
const {deployer}=await getNamedAccounts()
let vrfCoordinatorAddress
const chainId= network.config.chainId


/**checking for local network */
if(developmentChains.includes(network.name)){
   const vrfCoordinatorV2Mock= await deploy("VRFCoordinatorV2Mock")
   vrfCoordinatorAddress= vrfCoordinatorV2Mock.address
/**here we will be creating and calling the subscription id programmatically instead of using ui*/
const transactionResponse= vrfCoordinatorV2Mock.createSubscription()
//here the transactionResponse emits an event of subscription being called and we get it from transactionreceipt
const transactionReceipt= vrfCoordinatorV2Mock.waitConfirmations(1)
subscriptionId= transactionReceipt.events[0].args.subId
// funding the subscription
await vrfCoordinatorV2Mock.fundSubscription(subscriptionId,VRF_SUB_FUND_AMOUNT)

}else{
    vrfCoordinatorAddress=networkConfig[chainId]['vrfCoordinatorV2']
    subscriptionId=networkConfig[chainId]['subId']
}
const entranceFee=networkConfig[chainId]["entranceFee"]
const gasLane= networkConfig[chainId]["gasLane"]
const callbackGasLimit=networkConfig[chainId]["callbackGasLimit"]
const interval=networkConfig[chainId]["interval"]

const args=[vrfCoordinatorAddress,entranceFee,gasLane,subscriptionId,callbackGasLimit,interval]

const raffle= await deploy("Raffle",{
    from:deployer,
    args:args,
    log:true,
    waitConfirmations:network.config.blockConfirmations || 1,

})

if(!developmentChains && process.env.ETHERSCAN_API_KEY){
    console.log("Verifying.......")
    await verify(raffle.address,args)


}

log("-------------------------------------------------------------------------------------------------------------------------")

module.exports.tags=("all","raffle")


}

