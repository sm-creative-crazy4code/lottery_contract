// SPDX-License-Identifier:MIT
pragma solidity ^0.8.7;

error Raffle__InsufficientFunds();


contract Raffle{

//state variables 
uint256 private immutable i_entrancefee; //immutable variable
address payable[]  private s_players;// storage variables


constructor(uint256 entranceFee){
    i_entrancefee=entranceFee;

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

function getPlayers( uint256 index) public view  returns (address){
    return s_players[index]; 



}

}



//lottery 
//enter the lottery
//pick a random winner
//winner seclected every regular interval automatically
//chainlink==> randomness,automation(chainlink keepers)

