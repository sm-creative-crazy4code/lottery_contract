/**
 * we will only be deploying mocks only when we are on our development chain 
 * not incase of any test net
 */

const developmentChains= require ("../helper-hardhat-config")
const { deployments, network } = require("hardhat");

module.exports= async function ({ getNamedAccounts, deployments}){
const {deploy, logs}=deployments
const deployer = getNamedAccounts
const chainId= network.config.chainId

if(developmentChains.includes(network.name)){

    log("local network detected .... deploying mocks")
    // deploy the mock of vrf coordinator...
}


}