// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.10;

contract PihiLottery {
    address payable[] public players;
    address payable public admin;

    constructor() {
        admin = payable(msg.sender);
    }

    // receive 1 ether for each ticket
    receive() external payable {
        uint256 eth = msg.value;
        require(eth >= 1 ether, "Please send some ether");

        for (uint256 i = 0; i < eth; i += 1000000000000000000) {
            players.push(payable(msg.sender));
        }
    }

    function totalPlayer() public view returns (uint256) {
        return players.length;
    }

    function balance() public view returns (uint256) {
        require(msg.sender == admin, "Are you admin?");
        return address(this).balance;
    }

    function play() public {
        require(msg.sender == admin, "Only admin can start a spin.");

        uint256 numberOfPlayers = players.length;
        require(numberOfPlayers >= 3, "Few more tickets to be sold");

        uint256 winnerLocation = pickRandom() % players.length;

        address payable winner = players[winnerLocation];
        winner.transfer(address(this).balance - commission());

        players = new address payable[](0);
    }

    function extractProfit() public payable {
        require(msg.sender == admin, "Are you admin?");
        require(totalPlayer() == 0, "Lottery is in progress");

        admin.transfer(address(this).balance);
    }

    function commission() private view returns (uint256) {
        uint256 tp = totalPlayer();
        // Keeping 10 % commission
        return (tp * 1000000000000000000 * 1) / 10;
    }

    function pickRandom() private view returns (uint256) {
        return
            uint256(
                keccak256(
                    abi.encodePacked(block.difficulty, block.timestamp, players)
                )
            );
    }
}
