pragma solidity ^0.4.19;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    
  address public owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}


/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
    
  event Pause();
  event Unpause();

  bool public paused = false;

  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() onlyOwner whenNotPaused public {
    paused = true;
    Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused public {
    paused = false;
    Unpause();
  }
  
}


/**
 * @title Helps contracts guard agains reentrancy attacks.
 * @author Remco Bloemen <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="f183949c929eb1c3">[email protected]</a>π.com&gt;&#13;
 * @notice If you mark a function `nonReentrant`, you should also&#13;
 * mark it `external`.&#13;
 */&#13;
contract ReentrancyGuard {&#13;
&#13;
  /**&#13;
   * @dev We use a single lock for the whole contract.&#13;
   */&#13;
  bool private reentrancy_lock = false;&#13;
&#13;
  /**&#13;
   * @dev Prevents a contract from calling itself, directly or indirectly.&#13;
   * @notice If you mark a function `nonReentrant`, you should also&#13;
   * mark it `external`. Calling one nonReentrant function from&#13;
   * another is not supported. Instead, you can implement a&#13;
   * `private` function doing the actual work, and a `external`&#13;
   * wrapper marked as `nonReentrant`.&#13;
   */&#13;
  modifier nonReentrant() {&#13;
    require(!reentrancy_lock);&#13;
    reentrancy_lock = true;&#13;
    _;&#13;
    reentrancy_lock = false;&#13;
  }&#13;
&#13;
}&#13;
&#13;
&#13;
/**&#13;
 * @title Destructible&#13;
 * @dev Base contract that can be destroyed by owner. All funds in contract will be sent to the owner.&#13;
 */&#13;
contract Destructible is Ownable {&#13;
&#13;
  function Destructible() public payable { }&#13;
&#13;
  /**&#13;
   * @dev Transfers the current balance to the owner and terminates the contract.&#13;
   */&#13;
  function destroy() onlyOwner public {&#13;
    selfdestruct(owner);&#13;
  }&#13;
&#13;
  function destroyAndSend(address _recipient) onlyOwner public {&#13;
    selfdestruct(_recipient);&#13;
  }&#13;
  &#13;
}&#13;
&#13;
&#13;
/// @dev Interface to the Core Contract of Ether Dungeon.&#13;
contract EDCoreInterface {&#13;
&#13;
    /// @dev The external function to get all the game settings in one call.&#13;
    function getGameSettings() external view returns (&#13;
        uint _recruitHeroFee,&#13;
        uint _transportationFeeMultiplier,&#13;
        uint _noviceDungeonId,&#13;
        uint _consolationRewardsRequiredFaith,&#13;
        uint _challengeFeeMultiplier,&#13;
        uint _dungeonPreparationTime,&#13;
        uint _trainingFeeMultiplier,&#13;
        uint _equipmentTrainingFeeMultiplier,&#13;
        uint _preparationPeriodTrainingFeeMultiplier,&#13;
        uint _preparationPeriodEquipmentTrainingFeeMultiplier&#13;
    );&#13;
    &#13;
    /**&#13;
     * @dev The external function to get all the relevant information about a specific player by its address.&#13;
     * @param _address The address of the player.&#13;
     */&#13;
    function getPlayerDetails(address _address) external view returns (&#13;
        uint dungeonId, &#13;
        uint payment, &#13;
        uint dungeonCount, &#13;
        uint heroCount, &#13;
        uint faith,&#13;
        bool firstHeroRecruited&#13;
    );&#13;
    &#13;
    /**&#13;
     * @dev The external function to get all the relevant information about a specific dungeon by its ID.&#13;
     * @param _id The ID of the dungeon.&#13;
     */&#13;
    function getDungeonDetails(uint _id) external view returns (&#13;
        uint creationTime, &#13;
        uint status, &#13;
        uint difficulty, &#13;
        uint capacity, &#13;
        address owner, &#13;
        bool isReady, &#13;
        uint playerCount&#13;
    );&#13;
    &#13;
    /**&#13;
     * @dev Split floor related details out of getDungeonDetails, just to avoid Stack Too Deep error.&#13;
     * @param _id The ID of the dungeon.&#13;
     */&#13;
    function getDungeonFloorDetails(uint _id) external view returns (&#13;
        uint floorNumber, &#13;
        uint floorCreationTime, &#13;
        uint rewards, &#13;
        uint seedGenes, &#13;
        uint floorGenes&#13;
    );&#13;
&#13;
    /**&#13;
     * @dev The external function to get all the relevant information about a specific hero by its ID.&#13;
     * @param _id The ID of the hero.&#13;
     */&#13;
    function getHeroDetails(uint _id) external view returns (&#13;
        uint creationTime, &#13;
        uint cooldownStartTime, &#13;
        uint cooldownIndex, &#13;
        uint genes, &#13;
        address owner, &#13;
        bool isReady, &#13;
        uint cooldownRemainingTime&#13;
    );&#13;
&#13;
    /// @dev Get the attributes (equipments + stats) of a hero from its gene.&#13;
    function getHeroAttributes(uint _genes) public pure returns (uint[]);&#13;
    &#13;
    /// @dev Calculate the power of a hero from its gene, it calculates the equipment power, stats power, and super hero boost.&#13;
    function getHeroPower(uint _genes, uint _dungeonDifficulty) public pure returns (&#13;
        uint totalPower, &#13;
        uint equipmentPower, &#13;
        uint statsPower, &#13;
        bool isSuper, &#13;
        uint superRank,&#13;
        uint superBoost&#13;
    );&#13;
    &#13;
    /// @dev Calculate the power of a dungeon floor.&#13;
    function getDungeonPower(uint _genes) public pure returns (uint);&#13;
    &#13;
    /**&#13;
     * @dev Calculate the sum of top 5 heroes power a player owns.&#13;
     *  The gas usage increased with the number of heroes a player owned, roughly 500 x hero count.&#13;
     *  This is used in transport function only to calculate the required tranport fee.&#13;
     */&#13;
    function calculateTop5HeroesPower(address _address, uint _dungeonId) public view returns (uint);&#13;
    &#13;
}&#13;
&#13;
&#13;
/// @dev Core Contract of "Enter the Coliseum" game of the ED (Ether Dungeon) Platform.&#13;
contract EDColiseumAlpha is Pausable, ReentrancyGuard, Destructible {&#13;
    &#13;
    struct Participant {&#13;
        address player;&#13;
        uint heroId;&#13;
        uint heroPower;&#13;
    }&#13;
    &#13;
    /// @dev The address of the EtherDungeonCore contract.&#13;
    EDCoreInterface public edCoreContract = EDCoreInterface(0xf7eD56c1AC4d038e367a987258b86FC883b960a1);&#13;
    &#13;
    /// @dev Seed for the random number generator used for calculating fighting result.&#13;
    uint _seed;&#13;
    &#13;
    &#13;
    /* ======== SETTINGS ======== */&#13;
&#13;
    /// @dev The required win count to win a jackpot.&#13;
    uint public jackpotWinCount = 3;&#13;
    &#13;
    /// @dev The percentage of jackpot a player get when reaching the jackpotWinCount.&#13;
    uint public jackpotWinPercent = 50;&#13;
    &#13;
    /// @dev The percentage of rewards a player get when being the final winner of a tournament.&#13;
    uint public winPercent = 55;&#13;
    &#13;
    /// @dev The percentage of rewards a player get when being the final loser of a tournament, remaining will add to tournamentJackpot.&#13;
    uint public losePercent = 35;&#13;
    &#13;
    /// @dev Dungeon difficulty to be used when calculating super hero power boost, 1 is no boost.&#13;
    uint public dungeonDifficulty = 1;&#13;
&#13;
    /// @dev The required fee to join a participant&#13;
    uint public participationFee = 0.02 ether;&#13;
    &#13;
    /// @dev The maximum number of participants for a tournament.&#13;
    uint public constant maxParticipantCount = 8;&#13;
    &#13;
    &#13;
    /* ======== STATE VARIABLES ======== */&#13;
    &#13;
    /// @dev The next tournaments round number.&#13;
    uint public nextTournamentRound = 1;&#13;
&#13;
    /// @dev The current accumulated rewards pool.&#13;
    uint public tournamentRewards;&#13;
&#13;
    /// @dev The current accumulated jackpot.&#13;
    uint public tournamentJackpot = 0.2 ether;&#13;
    &#13;
    /// @dev Array of all the participant for next tournament.&#13;
    Participant[] public participants;&#13;
    &#13;
    /// @dev Array of all the participant for the previous tournament.&#13;
    Participant[] public previousParticipants;&#13;
    &#13;
    /// @dev Array to store the participant index all winners / losers for each "fighting round" of the previous tournament.&#13;
    uint[maxParticipantCount / 2] public firstRoundWinners;&#13;
    uint[maxParticipantCount / 4] public secondRoundWinners;&#13;
    uint[maxParticipantCount / 2] public firstRoundLosers;&#13;
    uint[maxParticipantCount / 4] public secondRoundLosers;&#13;
    uint public finalWinner;&#13;
    uint public finalLoser;&#13;
    &#13;
    /// @dev Mapping of hero ID to the hero's last participated tournament round to avoid repeated hero participation.&#13;
    mapping(uint =&gt; uint) public heroIdToLastRound;&#13;
    &#13;
    /// @dev Mapping of player ID to the consecutive win counts, used for calculating jackpot.&#13;
    mapping(address =&gt; uint) public playerToWinCounts;&#13;
&#13;
    &#13;
    /* ======== EVENTS ======== */&#13;
    &#13;
    /// @dev The PlayerTransported event is fired when user transported to another dungeon.&#13;
    event TournamentFinished(uint timestamp, uint tournamentRound, address finalWinner, address finalLoser, uint winnerRewards, uint loserRewards, uint winCount, uint jackpotRewards);&#13;
    &#13;
    /// @dev Payable constructor to pass in the initial jackpot ethers.&#13;
    function EDColiseum() public payable {}&#13;
&#13;
    &#13;
    /* ======== PUBLIC/EXTERNAL FUNCTIONS ======== */&#13;
    &#13;
    /// @dev The external function to get all the game settings in one call.&#13;
    function getGameSettings() external view returns (&#13;
        uint _jackpotWinCount,&#13;
        uint _jackpotWinPercent,&#13;
        uint _winPercent,&#13;
        uint _losePercent,&#13;
        uint _dungeonDifficulty,&#13;
        uint _participationFee,&#13;
        uint _maxParticipantCount&#13;
    ) {&#13;
        _jackpotWinCount = jackpotWinCount;&#13;
        _jackpotWinPercent = jackpotWinPercent;&#13;
        _winPercent = winPercent;&#13;
        _losePercent = losePercent;&#13;
        _dungeonDifficulty = dungeonDifficulty;&#13;
        _participationFee = participationFee;&#13;
        _maxParticipantCount = maxParticipantCount;&#13;
    }&#13;
    &#13;
    /// @dev The external function to get all the game settings in one call.&#13;
    function getNextTournamentData() external view returns (&#13;
        uint _nextTournamentRound,&#13;
        uint _tournamentRewards,&#13;
        uint _tournamentJackpot,&#13;
        uint _participantCount&#13;
    ) {&#13;
        _nextTournamentRound = nextTournamentRound;&#13;
        _tournamentRewards = tournamentRewards;&#13;
        _tournamentJackpot = tournamentJackpot;&#13;
        _participantCount = participants.length;&#13;
    }&#13;
    &#13;
    /// @dev The external function to call when joining the next tournament.&#13;
    function joinTournament(uint _heroId) whenNotPaused nonReentrant external payable {&#13;
        uint genes;&#13;
        address owner;&#13;
        (,,, genes, owner,,) = edCoreContract.getHeroDetails(_heroId);&#13;
        &#13;
        // Throws if the hero is not owned by the sender.&#13;
        require(msg.sender == owner);&#13;
        &#13;
        // Throws if the hero is already participated in the next tournament.&#13;
        require(heroIdToLastRound[_heroId] != nextTournamentRound);&#13;
        &#13;
        // Throws if participation count is full.&#13;
        require(participants.length &lt; maxParticipantCount);&#13;
        &#13;
        // Throws if payment not enough, any exceeding funds will be transferred back to the player.&#13;
        require(msg.value &gt;= participationFee);&#13;
        tournamentRewards += participationFee;&#13;
&#13;
        if (msg.value &gt; participationFee) {&#13;
            msg.sender.transfer(msg.value - participationFee);&#13;
        }&#13;
        &#13;
        // Set the hero participation round.&#13;
        heroIdToLastRound[_heroId] = nextTournamentRound;&#13;
        &#13;
        // Get the hero power and set it to storage.&#13;
        uint heroPower;&#13;
        (heroPower,,,,) = edCoreContract.getHeroPower(genes, dungeonDifficulty);&#13;
        &#13;
        // Throw if heroPower is 12 (novice hero).&#13;
        require(heroPower &gt; 12);&#13;
        &#13;
        // Set the participant data to storage.&#13;
        participants.push(Participant(msg.sender, _heroId, heroPower));&#13;
    }&#13;
    &#13;
    /// @dev The onlyOwner external function to call when joining the next tournament.&#13;
    function startTournament() onlyOwner nonReentrant external {&#13;
        // Throws if participation count is not full.&#13;
        require(participants.length == maxParticipantCount);&#13;
        &#13;
        // FIGHT!&#13;
        _firstRoundFight();&#13;
        _secondRoundWinnersFight();&#13;
        _secondRoundLosersFight();&#13;
        _finalRoundWinnersFight();&#13;
        _finalRoundLosersFight();&#13;
        &#13;
        // REWARDS!&#13;
        uint winnerRewards = tournamentRewards * winPercent / 100;&#13;
        uint loserRewards = tournamentRewards * losePercent / 100;&#13;
        uint addToJackpot = tournamentRewards - winnerRewards - loserRewards;&#13;
        &#13;
        address winner = participants[finalWinner].player;&#13;
        address loser = participants[finalLoser].player;&#13;
        winner.transfer(winnerRewards);&#13;
        loser.transfer(loserRewards);&#13;
        tournamentJackpot += addToJackpot;&#13;
        &#13;
        // JACKPOT!&#13;
        playerToWinCounts[winner]++;&#13;
        &#13;
        // Reset other participants' consecutive winCount.&#13;
        for (uint i = 0; i &lt; participants.length; i++) {&#13;
            address participant = participants[i].player;&#13;
            &#13;
            if (participant != winner &amp;&amp; playerToWinCounts[participant] != 0) {&#13;
                playerToWinCounts[participant] = 0;&#13;
            }&#13;
        }&#13;
        &#13;
        // Detemine if the winner have enough consecutive winnings for jackpot.&#13;
        uint jackpotRewards;&#13;
        uint winCount = playerToWinCounts[winner];&#13;
        if (winCount == jackpotWinCount) {&#13;
            // Reset consecutive winCount of winner.&#13;
            playerToWinCounts[winner] = 0;&#13;
            &#13;
            jackpotRewards = tournamentJackpot * jackpotWinPercent / 100;&#13;
            tournamentJackpot -= jackpotRewards;&#13;
            &#13;
            winner.transfer(jackpotRewards);&#13;
        }&#13;
        &#13;
        // Reset tournament data and increment round.&#13;
        tournamentRewards = 0;&#13;
        previousParticipants = participants;&#13;
        participants.length = 0;&#13;
        nextTournamentRound++;&#13;
        &#13;
        // Emit TournamentFinished event.&#13;
        TournamentFinished(now, nextTournamentRound - 1, winner, loser, winnerRewards, loserRewards, winCount, jackpotRewards);&#13;
    }&#13;
    &#13;
    /// @dev The onlyOwner external function to call to cancel the next tournament and refunds.&#13;
    function cancelTournament() onlyOwner nonReentrant external {&#13;
        for (uint i = 0; i &lt; participants.length; i++) {&#13;
            address participant = participants[i].player;&#13;
            &#13;
            if (participant != 0x0) {&#13;
                participant.transfer(participationFee);&#13;
            }&#13;
        }&#13;
        &#13;
        // Reset tournament data and increment round.&#13;
        tournamentRewards = 0;&#13;
        participants.length = 0;&#13;
        nextTournamentRound++;&#13;
    }&#13;
    &#13;
    /// @dev Withdraw all Ether from the contract.&#13;
    function withdrawBalance() onlyOwner external {&#13;
        // Can only withdraw if no participants joined (i.e. call cancelTournament first.)&#13;
        require(participants.length == 0);&#13;
        &#13;
        msg.sender.transfer(this.balance);&#13;
    }&#13;
&#13;
    /* ======== SETTER FUNCTIONS ======== */&#13;
    &#13;
    function setEdCoreContract(address _newEdCoreContract) onlyOwner external {&#13;
        edCoreContract = EDCoreInterface(_newEdCoreContract);&#13;
    }&#13;
    &#13;
    function setJackpotWinCount(uint _newJackpotWinCount) onlyOwner external {&#13;
        jackpotWinCount = _newJackpotWinCount;&#13;
    }&#13;
    &#13;
    function setJackpotWinPercent(uint _newJackpotWinPercent) onlyOwner external {&#13;
        jackpotWinPercent = _newJackpotWinPercent;&#13;
    }&#13;
    &#13;
    function setWinPercent(uint _newWinPercent) onlyOwner external {&#13;
        winPercent = _newWinPercent;&#13;
    }&#13;
    &#13;
    function setLosePercent(uint _newLosePercent) onlyOwner external {&#13;
        losePercent = _newLosePercent;&#13;
    }&#13;
    &#13;
    function setDungeonDifficulty(uint _newDungeonDifficulty) onlyOwner external {&#13;
        dungeonDifficulty = _newDungeonDifficulty;&#13;
    }&#13;
    &#13;
    function setParticipationFee(uint _newParticipationFee) onlyOwner external {&#13;
        participationFee = _newParticipationFee;&#13;
    }&#13;
    &#13;
    /* ======== INTERNAL/PRIVATE FUNCTIONS ======== */&#13;
    &#13;
    /// @dev Compute all winners and losers for the first round.&#13;
    function _firstRoundFight() private {&#13;
        // Get all hero powers.&#13;
        uint heroPower0 = participants[0].heroPower;&#13;
        uint heroPower1 = participants[1].heroPower;&#13;
        uint heroPower2 = participants[2].heroPower;&#13;
        uint heroPower3 = participants[3].heroPower;&#13;
        uint heroPower4 = participants[4].heroPower;&#13;
        uint heroPower5 = participants[5].heroPower;&#13;
        uint heroPower6 = participants[6].heroPower;&#13;
        uint heroPower7 = participants[7].heroPower;&#13;
        &#13;
        // Random number.&#13;
        uint rand;&#13;
        &#13;
        // 0 Vs 1&#13;
        rand = _getRandomNumber(100);&#13;
        if (&#13;
            (heroPower0 &gt; heroPower1 &amp;&amp; rand &lt; 60) || &#13;
            (heroPower0 == heroPower1 &amp;&amp; rand &lt; 50) ||&#13;
            (heroPower0 &lt; heroPower1 &amp;&amp; rand &lt; 40)&#13;
        ) {&#13;
            firstRoundWinners[0] = 0;&#13;
            firstRoundLosers[0] = 1;&#13;
        } else {&#13;
            firstRoundWinners[0] = 1;&#13;
            firstRoundLosers[0] = 0;&#13;
        }&#13;
        &#13;
        // 2 Vs 3&#13;
        rand = _getRandomNumber(100);&#13;
        if (&#13;
            (heroPower2 &gt; heroPower3 &amp;&amp; rand &lt; 60) || &#13;
            (heroPower2 == heroPower3 &amp;&amp; rand &lt; 50) ||&#13;
            (heroPower2 &lt; heroPower3 &amp;&amp; rand &lt; 40)&#13;
        ) {&#13;
            firstRoundWinners[1] = 2;&#13;
            firstRoundLosers[1] = 3;&#13;
        } else {&#13;
            firstRoundWinners[1] = 3;&#13;
            firstRoundLosers[1] = 2;&#13;
        }&#13;
        &#13;
        // 4 Vs 5&#13;
        rand = _getRandomNumber(100);&#13;
        if (&#13;
            (heroPower4 &gt; heroPower5 &amp;&amp; rand &lt; 60) || &#13;
            (heroPower4 == heroPower5 &amp;&amp; rand &lt; 50) ||&#13;
            (heroPower4 &lt; heroPower5 &amp;&amp; rand &lt; 40)&#13;
        ) {&#13;
            firstRoundWinners[2] = 4;&#13;
            firstRoundLosers[2] = 5;&#13;
        } else {&#13;
            firstRoundWinners[2] = 5;&#13;
            firstRoundLosers[2] = 4;&#13;
        }&#13;
        &#13;
        // 6 Vs 7&#13;
        rand = _getRandomNumber(100);&#13;
        if (&#13;
            (heroPower6 &gt; heroPower7 &amp;&amp; rand &lt; 60) || &#13;
            (heroPower6 == heroPower7 &amp;&amp; rand &lt; 50) ||&#13;
            (heroPower6 &lt; heroPower7 &amp;&amp; rand &lt; 40)&#13;
        ) {&#13;
            firstRoundWinners[3] = 6;&#13;
            firstRoundLosers[3] = 7;&#13;
        } else {&#13;
            firstRoundWinners[3] = 7;&#13;
            firstRoundLosers[3] = 6;&#13;
        }&#13;
    }&#13;
    &#13;
    /// @dev Compute all second winners of all first round winners.&#13;
    function _secondRoundWinnersFight() private {&#13;
        // Get all hero powers of all first round winners.&#13;
        uint winner0 = firstRoundWinners[0];&#13;
        uint winner1 = firstRoundWinners[1];&#13;
        uint winner2 = firstRoundWinners[2];&#13;
        uint winner3 = firstRoundWinners[3];&#13;
        uint heroPower0 = participants[winner0].heroPower;&#13;
        uint heroPower1 = participants[winner1].heroPower;&#13;
        uint heroPower2 = participants[winner2].heroPower;&#13;
        uint heroPower3 = participants[winner3].heroPower;&#13;
        &#13;
        // Random number.&#13;
        uint rand;&#13;
        &#13;
        // 0 Vs 1&#13;
        rand = _getRandomNumber(100);&#13;
        if (&#13;
            (heroPower0 &gt; heroPower1 &amp;&amp; rand &lt; 60) || &#13;
            (heroPower0 == heroPower1 &amp;&amp; rand &lt; 50) ||&#13;
            (heroPower0 &lt; heroPower1 &amp;&amp; rand &lt; 40)&#13;
        ) {&#13;
            secondRoundWinners[0] = winner0;&#13;
        } else {&#13;
            secondRoundWinners[0] = winner1;&#13;
        }&#13;
        &#13;
        // 2 Vs 3&#13;
        rand = _getRandomNumber(100);&#13;
        if (&#13;
            (heroPower2 &gt; heroPower3 &amp;&amp; rand &lt; 60) || &#13;
            (heroPower2 == heroPower3 &amp;&amp; rand &lt; 50) ||&#13;
            (heroPower2 &lt; heroPower3 &amp;&amp; rand &lt; 40)&#13;
        ) {&#13;
            secondRoundWinners[1] = winner2;&#13;
        } else {&#13;
            secondRoundWinners[1] = winner3;&#13;
        }&#13;
    }&#13;
    &#13;
    /// @dev Compute all second losers of all first round losers.&#13;
    function _secondRoundLosersFight() private {&#13;
        // Get all hero powers of all first round losers.&#13;
        uint loser0 = firstRoundLosers[0];&#13;
        uint loser1 = firstRoundLosers[1];&#13;
        uint loser2 = firstRoundLosers[2];&#13;
        uint loser3 = firstRoundLosers[3];&#13;
        uint heroPower0 = participants[loser0].heroPower;&#13;
        uint heroPower1 = participants[loser1].heroPower;&#13;
        uint heroPower2 = participants[loser2].heroPower;&#13;
        uint heroPower3 = participants[loser3].heroPower;&#13;
        &#13;
        // Random number.&#13;
        uint rand;&#13;
        &#13;
        // 0 Vs 1&#13;
        rand = _getRandomNumber(100);&#13;
        if (&#13;
            (heroPower0 &gt; heroPower1 &amp;&amp; rand &lt; 60) || &#13;
            (heroPower0 == heroPower1 &amp;&amp; rand &lt; 50) ||&#13;
            (heroPower0 &lt; heroPower1 &amp;&amp; rand &lt; 40)&#13;
        ) {&#13;
            secondRoundLosers[0] = loser1;&#13;
        } else {&#13;
            secondRoundLosers[0] = loser0;&#13;
        }&#13;
        &#13;
        // 2 Vs 3&#13;
        rand = _getRandomNumber(100);&#13;
        if (&#13;
            (heroPower2 &gt; heroPower3 &amp;&amp; rand &lt; 60) || &#13;
            (heroPower2 == heroPower3 &amp;&amp; rand &lt; 50) ||&#13;
            (heroPower2 &lt; heroPower3 &amp;&amp; rand &lt; 40)&#13;
        ) {&#13;
            secondRoundLosers[1] = loser3;&#13;
        } else {&#13;
            secondRoundLosers[1] = loser2;&#13;
        }&#13;
    }&#13;
    &#13;
    /// @dev Compute the final winner.&#13;
    function _finalRoundWinnersFight() private {&#13;
        // Get all hero powers of all first round winners.&#13;
        uint winner0 = secondRoundWinners[0];&#13;
        uint winner1 = secondRoundWinners[1];&#13;
        uint heroPower0 = participants[winner0].heroPower;&#13;
        uint heroPower1 = participants[winner1].heroPower;&#13;
        &#13;
        // Random number.&#13;
        uint rand;&#13;
        &#13;
        // 0 Vs 1&#13;
        rand = _getRandomNumber(100);&#13;
        if (&#13;
            (heroPower0 &gt; heroPower1 &amp;&amp; rand &lt; 60) || &#13;
            (heroPower0 == heroPower1 &amp;&amp; rand &lt; 50) ||&#13;
            (heroPower0 &lt; heroPower1 &amp;&amp; rand &lt; 40)&#13;
        ) {&#13;
            finalWinner = winner0;&#13;
        } else {&#13;
            finalWinner = winner1;&#13;
        }&#13;
    }&#13;
    &#13;
    /// @dev Compute the final loser.&#13;
    function _finalRoundLosersFight() private {&#13;
        // Get all hero powers of all first round winners.&#13;
        uint loser0 = secondRoundLosers[0];&#13;
        uint loser1 = secondRoundLosers[1];&#13;
        uint heroPower0 = participants[loser0].heroPower;&#13;
        uint heroPower1 = participants[loser1].heroPower;&#13;
        &#13;
        // Random number.&#13;
        uint rand;&#13;
        &#13;
        // 0 Vs 1&#13;
        rand = _getRandomNumber(100);&#13;
        if (&#13;
            (heroPower0 &gt; heroPower1 &amp;&amp; rand &lt; 60) || &#13;
            (heroPower0 == heroPower1 &amp;&amp; rand &lt; 50) ||&#13;
            (heroPower0 &lt; heroPower1 &amp;&amp; rand &lt; 40)&#13;
        ) {&#13;
            finalLoser = loser1;&#13;
        } else {&#13;
            finalLoser = loser0;&#13;
        }&#13;
    }&#13;
    &#13;
    // @dev Return a pseudo random uint smaller than lower bounds.&#13;
    function _getRandomNumber(uint _upper) private returns (uint) {&#13;
        _seed = uint(keccak256(&#13;
            _seed,&#13;
            block.blockhash(block.number - 1),&#13;
            block.coinbase,&#13;
            block.difficulty&#13;
        ));&#13;
        &#13;
        return _seed % _upper;&#13;
    }&#13;
&#13;
}