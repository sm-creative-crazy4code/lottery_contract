
const { assert, expect } = require("chai")
const { deployContract } = require("ethereum-waffle")
const { network, getNamedAccounts, deployments, ethers } = require("hardhat")
const {developmentChains,networkConfig}=require("../../helper-hardhat-config")

!developmentChains.includes(network.name)?describe.skip:describe(
    "Raffle Unit Test", async function(){
     let raffle, vrfCoordinatorV2Mock,raffleEntranceFee,deployer,interval
     const chainId= network.config.chainId

/** @dev 
 * before each test we wish to get some named accounts
 */

beforeEach(async function(){
 deployer= (await  getNamedAccounts()).deployer
await deployments.fixture("all")
raffle =await ethers.getContract("Raffle",deployer)
vrfCoordinatorV2Mock= await ethers.getContract("VRFCoordinatorV2Mock", deployer)
raffleEntranceFee = await raffle.getEntrancefee()
  interval = await raffle.getInterval()



})
 describe("constructor", function(){

    it("Intializes raffle correctly", async function(){


        const raffleState= await raffle.getRaffleState()
        
        assert.equal(raffleState.toString(),"0")
        assert.equal(interval.toString(),networkConfig[chainId]["interval"])
    })

 })

 describe("enterRaffle",  function(){
it("reverts if not paid enough", async function(){
    
    await expect(raffle.enterRaffle()).to.be.revertedWith("Raffle__InsufficientFunds")
  })
  it("records players as they enter", async function(){
    await raffle.enterRaffle({ value:raffleEntranceFee})
    const playerOfRaffle= raffle.getPlayers(0)
    assert.equal(playerOfRaffle,deployer)

  })
  /**matching tests with event emmited */
  it("emits event on entery of participants",async function(){
    await expect(raffle.enterRaffle()).to.emit(raffle,"RaffleEnter")
    /*hardhat envm time allows to do  something like hardhat time travel so as to deploy the contract for testing */
    await network.provider.send("evm_increaseTime", (interval.toNumber()+1))
   /**ensuring that checkupkeep returns true mining an empty block with empty array as params */
   await network.provider.send("evm_mine",[])
   /**pertending to be a chainlink keeper */
   await raffle.performUpkeep([])
   expect(raffle.enterRaffle()).to.be.revertedWith("Raffle__UpkeepNotNeeded")

  })


 })

 describe("checkUpkeep", function(){
    it("false if people have not send any eth",async function(){
        await network.provider.send("evm_increaseTime", (interval.toNumber()+1))
        await network.provider.send("evm_mine",[]) 
        /**here to stimulate the calling of the function without using to actually sending transaction we use call stpck
          here we will only be returning the upkeep needed and not the other values* */ 
          const {upkeepNeeded}= await raffle.callStatic.checkUpkeep([])//it is returning false as it is not funded
         assert(!upkeepNeeded)
    })

    it("return false if raffle is not open",async function(){
        await raffle.enterRaffle({ value:raffleEntranceFee})
        await network.provider.send("evm_increaseTime", (interval.toNumber()+1))
        await network.provider.send("evm_mine",[]) 
        await raffle.performUpkeep([])// same as await raffle.performUpkeep("x0")
        const raffleState= await raffle.getRaffleState()
        const {upkeepNeeded}= await raffle.callStatic.checkUpkeep([])
        assert.equal(raffleState.toString(),"1")
        assert.equal(upkeepNeeded,false)
    })

    it("returns false if enough time has not passed", async function(){
        await raffle.enterRaffle({ value:raffleEntranceFee})
        await network.provider.send("evm_increaseTime", (interval.toNumber()-1))
        await network.provider.send("evm_mine",[]) 
        const {upkeepNeeded}= await raffle.callStatic.checkUpkeep([])
        assert(!upkeepNeeded)  

    })

    it("returns true if enough time has passed ,has players, has entrance fee and is open",async function(){

        await raffle.enterRaffle({ value:raffleEntranceFee})
        await network.provider.send("evm_increaseTime", (interval.toNumber()+1))
        await network.provider.send("evm_mine",[]) 
        const {upkeepNeeded}= await raffle.callStatic.checkUpkeep([])
        assert(upkeepNeeded)  


    })
 })
 describe("performUpkeep",function(){
    it(" it can only run if check upkeep is true",async function(){
    await raffle.enterRaffle({ value:raffleEntranceFee})
    await network.provider.send("evm_increaseTime", (interval.toNumber()+1))
    await network.provider.send("evm_mine",[]) 
    const tx = await raffle.performUpkeep([])
    assert(tx)

    })
    it("reverts when check upkeep is false", async function(){
    await expect(raffle.performUpkeep([])).to.be.revertedWith("Raffle__UpkeepNotNeeded")//here we can also add the parameters using string interpolation

    })
    it("updates the raffle state, emits an event and calls the vrf coordinatou v2", async function(){
        await raffle.enterRaffle({ value:raffleEntranceFee})
        await network.provider.send("evm_increaseTime", (interval.toNumber()+1))
        await network.provider.send("evm_mine",[]) 
        const txrecipt = await raffle.performUpkeep()
        const txresponse =  await txrecipt.wait(1)
        /**AS vrf coordinator v2  is called before and it emits the oth event first and hence the event index is 1 not 0*/
        const requestId= txresponse.events[1].args.requestId
        const raffleState = await raffle.getRaffleState()
        assert(requestId.toNumber()>=0)
        assert( raffleState.toString() == "1")
    })
 })

 describe("fulfillRandomWords", function(){
    beforeEach(async function(){
        // before any testing is performed it is requires that somdeone enters the lottery 
        await raffle.enterRaffle({ value:raffleEntranceFee})
        await network.provider.send("evm_increaseTime", (interval.toNumber()+1))
        await network.provider.send("evm_mine",[]) 

    })
    // this function can only  be called as long as request requestRandomWords has been called
    // chainlink nodes actually calls a fullfill random words which calls another contract needed for random number verification
    // if request doesn't exist we get a non existent error
    it("can only be called after performkeep",async function(){
        await expect(vrfCoordinatorV2Mock.fulfillRandomWords(0,raffle.address)).to.be.revertedWith("nonexistent request")
        await expect(vrfCoordinatorV2Mock.fulfillRandomWords(1,raffle.address)).to.be.revertedWith("nonexistent request")
 

    })

    it("picks the winner ,resets the lottery and sends money",async function(){
     const additionalEntrances=3 //getting some new accounts
     const startingAccountIndex= 1//since index 0 is deployer
     const accounts= await ethers.getSigner()
    // making 3 additinal people enter the contract 
     for(let i = startingAccountIndex;i<startingAccountIndex+additionalEntrances;i++){
        const accountConnectRaffle = raffle.connect(accounts[i])
        await accountConnectRaffle.enterRaffle({ value:raffleEntranceFee})

     }
     const startingTimeStamp= await raffle.getLastTimeStamp()
     /**call performUpkeep as mock==>fullfillRandomWords as mock ===> pretend to be chainlink vrf==>wait till fullfillraandomwords is called
 * but on local network we dont have to wait and instead stimulate for waiting for the event to be called
 * hence we setup a listener and donot want to finish the test before the listener has stopped listening
 * hence creating a new promise
 *
 */
await new Promise(async(resolve,reject)=>{
    // listen for winner picked event and then do some stuff
    raffle.once("WinnerPicked",async ()=>{
      console.log("found the event")
        try {
            const RecentWinner=await raffle.getRecentWinner()
            console.log(RecentWinner)
            console.log( accounts[1].address)
            console.log( accounts[0].address)
            console.log( accounts[2].address)
            console.log( accounts[3].address)
            
            const RaffleState=await raffle.getRaffleState()
            const lastTimeStamp=await raffle.getlatestTimestamp()
            const noOfPlayers=await raffle.getNunberOfPlayer()
            const winnerEndingBalance = await  accounts[1].getBalance()
            assert.equal(RaffleState.toString(),"0")
            assert.equal(noOfPlayers.toString(),"0")
            assert( lastTimeStamp>startingTimeStamp )
            assert.equal(winnerEndingBalance,winnerStartingBalance.add(raffleEntranceFee.mul( additionalEntrances).add(raffleEntranceFee).toString()))
        } catch (error) {
            reject(error)
        }
     resolve()//if the event doesnt fires in 200 secs then consider as failure and resolve
    })
   
    //listener is activated which will fire the event..so puting all the code inside the promise 

    const tx= await raffle.performUpkeep([])
    const txrecipt=await tx.wait(1)
    // by running the script we know that account 1 is the winner and getting the winner starting balance
    const winnerStartingBalance=await accounts[1].getBalance()
    await vrfCoordinatorV2Mock.fulfillRandomWords(txrecipt.events[1].args.requestId,raffle.addess)
})



    })



// it("generates a random number",async function(){
 

// })


 })

    }
)