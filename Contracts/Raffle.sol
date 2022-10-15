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

function enterRaffle() public payable{
    if(msg.value< i_entrancefee){
   revert Raffle__InsufficientFunds();
    }
    s_players.push(payable(msg.sender));

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

