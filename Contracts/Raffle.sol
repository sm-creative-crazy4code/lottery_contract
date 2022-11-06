// SPDX-License-Identifier:MIT
pragma solidity ^0.8.7;
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/AutomationCompatible.sol";





error Raffle__InsufficientFunds();
error Raffle__TransactionFailure();
error Raffle__notOpen();
error Raffle__UpkeepNotNeeded(
  uint256 currentBalance,
  uint256 NumPlayers,
  uint256 RaffleState
);


/** @title a sample raffle contract
*   @author Sneha Mandal
    @notice this contract impliments a decentralized impennetrable smart contract
    @dev this includes the implimentationo of chainlink Vrf and ChainlinK automation

 */

abstract contract Raffle is VRFConsumerBaseV2, AutomationCompatibleInterface {
// we need to inherit from chainkink
/**;function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal virtual;
the above function imported from the smart contract and hence it is expected to be overidden


in the VRFConsumerBaseV2 function we need to pass the vrf coordinator parameter
 */



  // enum = coustum types with finite set of constant values
  enum RaffleState {
    OPEN,
    CALCULATING
  }

  /**importing the interfaces */
  VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
  bytes32 private immutable i_gaslane;
  uint64 private immutable i_subscription_id;
  uint32 private immutable i_callbackGasLimit;
  uint16 private constant REQUEST_CONFIRMATION = 3;
  uint32 private constant NUM_WORDS = 1;
  //state variables
  uint256 private immutable i_entrancefee; //immutable variable
  address payable[] private s_players; // storage variables
  address private s_mostRecentWinner;
  RaffleState private s_raffleState;
  uint256 private s_last_timestamp;
  uint256 private immutable i_interval;

  //lottery variable

  constructor(
    address vrfCoordinator,
    uint256 entranceFee,
    bytes32 gasLane,
    uint64 subscription_id,
    uint32 callbackGasLimit,
    uint256 interval
  ) VRFConsumerBaseV2(vrfCoordinator) {
    i_entrancefee = entranceFee;

    /**only settiing vrfCoordinator  one time inside the constructor*/
    i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinator);
    i_gaslane = gasLane;
    i_callbackGasLimit = callbackGasLimit;
    i_subscription_id = subscription_id;
    s_raffleState = RaffleState.OPEN;
    s_last_timestamp = block.timestamp;
    i_interval = interval;
  }

  
  event RaffleEnter(address indexed player);

  function enterRaffle() public payable {
    if (msg.value < i_entrancefee) {
      revert Raffle__InsufficientFunds();
    }

    if (s_raffleState != RaffleState.OPEN) {
      revert Raffle__notOpen();
    }

    s_players.push(payable(msg.sender));

    emit RaffleEnter(msg.sender);
  }

/** @dev bytes32 s_keyHash: The gas lane key hash value, 
which is the maximum gas price you are willing to pay for a request in wei. 
It functions as an ID of the off-chain VRF job that runs in response to requests. hence if gas prices are high then random number will not be called

uint64 s_subscriptionId: The subscription ID that this contract uses for funding requests. it is an contrac on chain that we use to do any computation or any  work

uint16 requestConfirmations: How many confirmations the Chainlink node should wait before responding.
 The longer the node waits, the more secure the random value is. It must be greater than the minimumRequestBlockConfirmations limit on the coordinator contract.

 callbackGasLimit: The limit for how much gas to use for the callback request to your contract's fulfillRandomWords function. 
 It must be less than the maxGasLimit
*/

  /** @dev chiain link vrf is a 2 transaction process
       it is better to get random number in  two transaction than having in just one
       because then it can be brute forced and manupulated by calling it and hence it will be unfair
       this function only request the random number
       in another function we will be getting and processing it*/

  /** @dev Picking a radom winner and implementing chainlink vrf
           using modulo operater
           here in this we will returned a random word array but as we are returning only one word the array will of size 1

 */

  function pickRandomNumber() external {}

/** @dev
CONCEPT OF EVENTS IN SOLIDITY
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
 non indexded are cost less gas
*/

/** @dev theu function will be  using chainlink automation to  execute it automatically after a fixed duration of time
  bytes calldata /* checkData *==> allows us to spicify anything when the function is called anf even be spified to call other functions as well
  this is the function the chain link keeper will call just to look for the upkeep and return true if upkeep or updation needed
  ****fallowing should be true in order to return true
  1.time limit should have passed 
  2. there is atleast one player 
  3.subscription to chainlink should be funded
  4.lottery should be in open state
*/

  function checkUpkeep(
    bytes memory /* checkData */
  )
    public
    view
    override
    returns (
      bool upkeepNeeded,
      bytes memory /* performData */
    )
  {
    bool isOpen = (RaffleState.OPEN == s_raffleState);
    bool timePassed = ((block.timestamp - s_last_timestamp) > i_interval);
    bool hasPlayers = (s_players.length > 0);
    bool hasBalance = (address(this).balance > 0);
    upkeepNeeded = (isOpen && timePassed && hasPlayers && hasBalance);
  }

  event RequestRaffleWinner(uint256 indexed requestId);
  /** @dev when check upkeep returns true perform upkeep is automatically called
   */

  function performUpkeep(
    bytes calldata /* performData */
  ) external override {
    (bool upkeepNeeded, ) = checkUpkeep("");
    if (!upkeepNeeded) {
      revert Raffle__UpkeepNotNeeded(
        address(this).balance,
        s_players.length,
        uint256(s_raffleState)
      );
    }

    s_raffleState = RaffleState.CALCULATING;
    uint256 requestId = i_vrfCoordinator.requestRandomWords(
      i_gaslane,
      i_subscription_id,
      REQUEST_CONFIRMATION,
      i_callbackGasLimit,
      NUM_WORDS
    );

    emit RequestRaffleWinner(requestId);
  }

  event winnerPicked(address indexed winner);

  function fulfillRandomWords(
    uint256, /*requestId*/
    uint256[] memory randomWords
  ) internal override {
    uint256 indexOfWinner = randomWords[0] % s_players.length;
    address payable recentWinner = s_players[indexOfWinner];
    s_mostRecentWinner = recentWinner;
    s_raffleState = RaffleState.OPEN;
    s_players = new address payable[](0);
    s_last_timestamp = block.timestamp;
    (bool success, ) = recentWinner.call{ value: address(this).balance }(" ");
    if (!success) {
      revert Raffle__TransactionFailure();
    }
    /**  actually requesting a random word and hence callingl the function which we need to call form the coordinator contract*/
    emit winnerPicked(recentWinner);
  }


  function getEntrancefee() public view returns (uint256) {
    return i_entrancefee;
  }



  function getPlayers(uint256 index) public view returns (address) {
    return s_players[index];
  }

  function getRecentWinner() public view returns (address) {
    return s_mostRecentWinner;
  }
function getRaffleState() public view returns (RaffleState ){
    return s_raffleState;

}

/**@dev since numwords is a constnat variable so technically it is not reading for storage and hence it's visibility can be restricted to pure */
function getNumWords() public pure returns(uint32){
    return NUM_WORDS;


}

function getNunberOfPlayer()public view returns( uint256){

    return s_players.length;
}

function getlatestTimestamp()public view returns( uint256){

    return s_last_timestamp;


}


function getRquestCofirmation()public pure returns( uint256){

    return REQUEST_CONFIRMATION ;


}


function getInterval() public view returns ( uint256){ 

  return i_interval;
}

//lottery
//enter the lottery
//pick a random winner
//winner seclected every regular interval automatically
//chainlink==> randomness,automation(chainlink keepers)
}