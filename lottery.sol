// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract Lottery {
    address payable[] public players;
    address payable public manager;
    address[] public allWinners;

    constructor(){
        manager = payable(msg.sender);
    }
    // Modifier to allow only the manager to execute the function
    modifier onlyManager() {
        require(msg.sender == manager, "Only the manager can execute this");
        _; // Continue with the function execution if the modifier's condition is met
    }

    receive() external payable{
        require(msg.value == 0.1 ether, "Invalid amount. Send 0.1 ETH to be included in the lottery.");
        require(msg.sender != manager);
        players.push(payable(msg.sender));
    }

    function getBalance() public onlyManager view returns(uint256) {
        return address(this).balance;           //address(this) refers to the address of the current smart contract instance.
    }

    function random() public view returns(uint256) {
        return uint256(keccak256(abi.encodePacked(block.prevrandao, block.timestamp, players.length)));
    }

    function pickWinner() public onlyManager {
        require(players.length >= 3);
        uint256 r = random();
        address payable winner;
    
        uint index = r % players.length;
        winner = players[index];
        allWinners.push(winner);

        uint256 managersFee = getBalance() * 10 / 100;
        manager.transfer(managersFee);

        winner.transfer(getBalance());


        players = new address payable[](0); //resetting the lottery
    }
}
