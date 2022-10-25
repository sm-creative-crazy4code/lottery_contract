const { deployments } = require("hardhat")

module.exports= async function({getNamedAccounts,deplonments}){

const {deploy,logs}=deployments
const {deployer}=await getNamedAccounts()
const raffle= await deploy("Raffle",{
    from:deployer,
    args:[],
    log:true,
    waitConfirmations:6,
    
})
}