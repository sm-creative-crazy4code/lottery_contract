// SPDX-License-Identifier:MIT
pragma solidity ^0.8.7;
import '@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol';
import '@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol';



// we need to inherit from chainkink
/**;function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal virtual;
the above function imported from the smart contract and hence it is expected to be overidden


in the VRFConsumerBaseV2 function we need to pass the vrf coordinator parameter
 */

error Raffle__InsufficientFunds();


contract Raffle is VRFConsumerBaseV2{ 

 /**importing the interfaces */
VRFCoordinatorV2Interface  privare immutable i_vrfCoordinator;
bytes32 private immutable i_gaslane;
uint64 private immutable i_subscription_id;
uint32 private immutable i_ callbackGasLimit;
uint16 private constant REQUEST_CONFIRMATION = 3;
uint32 private constant NUM_WORDS=1;
//state variables 
uint256 private immutable i_entrancefee; //immutable variable
address payable[]  private s_players;// storage variables


  constructor( address vrfCoordinator ,uint256 entranceFee, bytes32 gasLane,uint64 subscription_id, uint32  callbackGasLimit )VRFConsumerBaseV2(vrfCoordinator) {
    i_entrancefee=entranceFee;
    /**only settiing vrfCoordinator  one time inside the condtructor*/
    i_vrfCoordinator=VRFCoordinatorV2Interface(vrfCoordinator);
    i_gaslane = gaslane;
    i_callbackGasLimit= callbackGasLimit


}



function getEntrancefee() view public returns (uint){
    return i_entrancefee;

}

event RaffleEnter( address indexed player);

function enterRaffle() public payable{
    if(msg.value< i_entrancefee){
   revert Raffle__InsufficientFunds();
    }
    s_players.push(payable(msg.sender));

    emit RaffleEnter(msg.sender);

}



/**bytes32 s_keyHash: The gas lane key hash value, 
which is the maximum gas price you are willing to pay for a request in wei. 
It functions as an ID of the off-chain VRF job that runs in response to requests. hence if gas prices are high then random number will not be called

uint64 s_subscriptionId: The subscription ID that this contract uses for funding requests. it is an contrac on chain that we use to do any computation or any  work

uint16 requestConfirmations: How many confirmations the Chainlink node should wait before responding.
 The longer the node waits, the more secure the random value is. It must be greater than the minimumRequestBlockConfirmations limit on the coordinator contract.

 callbackGasLimit: The limit for how much gas to use for the callback request to your contract's fulfillRandomWords function. 
 It must be less than the maxGasLimit
*/
 event RequestRaffleWinner(uint256 indexed requestId);
function requestRandomNumber()external{

  uint256 requestId= i_vrfCoordinator.requestRandomWords(
        i_gaslane,
        i_subscription_id,
        REQUEST_CONFIRMATION,
        callbackGasLimit,
        NUM_WORDS
      )

emit RequestRaffleWinner(requestId);

}


//chiain link vrf is a 2 transaction process
// it is better to get random number in  two transaction than having in just one
// because then it can be brute forced and manupulated by calling it and hence it will be unfair
//this function only request the random number
// in another function we will be getting and processing it

function pickRandomNumber() external{




}

/**CONSEPT OF EVENTS IN SOLIDITY
Whenever we are changing any dynamic array we want to emit an event
most of the block has evm which has a logging functionality 
when anythinfg happpens on the blockchain then the evm writes these things on specific data structures called logs
an f get logs call can be made whenever we are connecting to a node to get the logs
 events are also one important kind of log 
 events allows to print information to the logging sturcture in a way that is more gas efficient ie by saving it to storage variable
 events and logs live in a special data structure is not available to smart contract and hence it is cheaper
 we can print some information that is important to us in without having to save it in a storage variable inside smart contract
 each of these event is tied to the account address that emmited this event and hence tied to the smart contract in this way

 suppose we want to do something  whenever some calls the transfer function and hence indtead from reading from the blockchain we can simply add 
 an event and lidten for it

 it is extreamly important for off chain infra structure as when ever a transaction completes  the website reloads as it was actually listening to the events

 when there are too many event the we need to index them so that they make sense and hence we need graphs
 when we emit events there are two types of parmeters inexed parameters and non indexed parameters
 we can have upto 3 indexed parameters and they are also known as topics
 indexed parameter are easily searchable
 non indexed parameter gets abiencoded and hence are difficult to search for
 we need to emit the event to store it in the logging data structure of blockchain
*/


function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal override{
    /**  actually requesting a random word and hence callingl the function which we need to call form the coordinator contract*/


}


function getPlayers( uint256 index) public view  returns (address){
    return s_players[index]; 



}

}



//lottery 
//enter the lottery
//pick a random winner
//winner seclected every regular interval automatically
//chainlink==> randomness,automation(chainlink keepers)

