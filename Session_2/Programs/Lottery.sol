// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Lottery {
    address public manager; // Address of the lottery manager
    address[] public players; // Addresses of participants
    uint256 public ticketPrice; // Price to enter the lottery
    uint256 public winnerIndex; // Index of the winner in the players array
    bool public lotteryEnded; // Flag to indicate if the lottery has ended
    
    // Event emitted when a player enters the lottery
    event PlayerEntered(address indexed player, uint256 ticketPrice);
    
    // Event emitted when a winner is picked
    event WinnerPicked(address indexed winner, uint256 prizeAmount);
    
    constructor(uint256 _ticketPrice) {
        manager = msg.sender;
        ticketPrice = _ticketPrice;
    }
    
    // Function to enter the lottery
    function enter() public payable {
        require(!lotteryEnded, "Lottery has ended");
        require(msg.value == ticketPrice, "Incorrect ticket price");
        
        players.push(msg.sender);
        
        emit PlayerEntered(msg.sender, ticketPrice);
    }
    
    // Function for the manager to pick a winner
    function pickWinner() public {
        require(msg.sender == manager, "Only the manager can call this");
        require(players.length > 0, "No players in the lottery");
        
        // Generate a pseudo-random number using block.timestamp and player count
        uint256 randomIndex = uint256(keccak256(abi.encodePacked(block.timestamp, players.length))) % players.length;
        
        winnerIndex = randomIndex;
        address winner = players[randomIndex];
        
        // Transfer the entire contract balance to the winner
        uint256 prizeAmount = address(this).balance;
        payable(winner).transfer(prizeAmount);
        
        lotteryEnded = true;
        
        emit WinnerPicked(winner, prizeAmount);
    }
    
    // Function to get the list of players
    function getPlayers() public view returns (address[] memory) {
        return players;
    }
}
