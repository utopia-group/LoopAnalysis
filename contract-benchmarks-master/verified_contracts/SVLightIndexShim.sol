pragma solidity ^0.4.19;


//
// SVLightBallotBox
// Single use contract to manage a ballot
// Author: Max Kaye <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="dfb2bea79facbabcaaadbaf1a9b0abba">[email protected]</a>&gt;&#13;
// (c) SecureVote 2018&#13;
//&#13;
// Architecture:&#13;
// * Ballot authority declares public key with which to encrypt ballots (optional - stored in ballot spec)&#13;
// * Users submit encrypted or plaintext ballots as blobs (dependent on above)&#13;
// * These ballots are tracked by the ETH address of the sender&#13;
// * Following the conclusion of the ballot, the secret key is provided&#13;
//   by the ballot authority, and all users may transparently and&#13;
//   independently validate the results&#13;
//&#13;
// Notes:&#13;
// * Since ballots are encrypted the only validation we can do is length, but UI takes care of most of the rest&#13;
//&#13;
&#13;
&#13;
contract SVLightBallotBox {&#13;
    //// ** Storage Variables&#13;
&#13;
    // Std owner pattern&#13;
    address public owner;&#13;
&#13;
    // test mode - operations like changing start/end times&#13;
    bool public testMode = false;&#13;
&#13;
    // struct for ballot&#13;
    struct Ballot {&#13;
        bytes32 ballotData;&#13;
        address sender;&#13;
        // we use a uint32 here because addresses are 20 bytes and this might help&#13;
        // solidity pack the block number well. gives us a little room to expand too if needed.&#13;
        uint32 blockN;&#13;
    }&#13;
&#13;
    // Maps to store ballots, along with corresponding log of voters.&#13;
    // Should only be modified through `addBallotAndVoter` internal function&#13;
    mapping (uint256 =&gt; Ballot) public ballotMap;&#13;
    mapping (uint256 =&gt; bytes32) public associatedPubkeys;&#13;
    uint256 public nVotesCast = 0;&#13;
&#13;
    // Use a map for voters to look up their ballot&#13;
    mapping (address =&gt; uint256) public voterToBallotID;&#13;
&#13;
    // NOTE - We don't actually want to include the PublicKey because _it's included in the ballotSpec_.&#13;
    // It's better to ensure ppl actually have the ballot spec by not including it in the contract.&#13;
    // Plus we're already storing the hash of the ballotSpec anyway...&#13;
&#13;
    // Private key to be set after ballot conclusion - curve25519&#13;
    bytes32 public ballotEncryptionSeckey;&#13;
    bool seckeyRevealed = false;&#13;
&#13;
    // Timestamps for start and end of ballot (UTC)&#13;
    uint64 public startTime;&#13;
    uint64 public endTime;&#13;
    uint64 public creationBlock;&#13;
    uint64 public startingBlockAround;&#13;
&#13;
    // specHash by which to validate the ballots integrity&#13;
    bytes32 public specHash;&#13;
    bool public useEncryption;&#13;
&#13;
    // deprecation flag - doesn't actually do anything besides signal that this contract is deprecated;&#13;
    bool public deprecated = false;&#13;
&#13;
    //// ** Events&#13;
    event CreatedBallot(address _creator, uint64[2] _openPeriod, bool _useEncryption, bytes32 _specHash);&#13;
    event SuccessfulPkVote(address voter, bytes32 ballot, bytes32 pubkey);&#13;
    event SuccessfulVote(address voter, bytes32 ballot);&#13;
    event SeckeyRevealed(bytes32 secretKey);&#13;
    event TestingEnabled();&#13;
    event Error(string error);&#13;
    event DeprecatedContract();&#13;
    event SetOwner(address _owner);&#13;
&#13;
&#13;
    //// ** Modifiers&#13;
&#13;
    modifier onlyOwner {&#13;
        require(msg.sender == owner);&#13;
        _;&#13;
    }&#13;
&#13;
    modifier ballotOpen {&#13;
        require(uint64(block.timestamp) &gt;= startTime &amp;&amp; uint64(block.timestamp) &lt; endTime);&#13;
        _;&#13;
    }&#13;
&#13;
    modifier onlyTesting {&#13;
        require(testMode);&#13;
        _;&#13;
    }&#13;
&#13;
    modifier isTrue(bool _b) {&#13;
        require(_b == true);&#13;
        _;&#13;
    }&#13;
&#13;
    modifier isFalse(bool _b) {&#13;
        require(_b == false);&#13;
        _;&#13;
    }&#13;
&#13;
    //// ** Functions&#13;
&#13;
    uint16 constant F_USE_ENC = 0;&#13;
    uint16 constant F_TESTING = 1;&#13;
    // Constructor function - init core params on deploy&#13;
    // timestampts are uint64s to give us plenty of room for millennia&#13;
    // flags are [_useEncryption, enableTesting]&#13;
    function SVLightBallotBox(bytes32 _specHash, uint64[2] openPeriod, bool[2] flags) public {&#13;
        owner = msg.sender;&#13;
&#13;
        // take the max of the start time provided and the blocks timestamp to avoid a DoS against recent token holders&#13;
        // (which someone might be able to do if they could set the timestamp in the past)&#13;
        startTime = max(openPeriod[0], uint64(block.timestamp));&#13;
        endTime = openPeriod[1];&#13;
        useEncryption = flags[F_USE_ENC];&#13;
        specHash = _specHash;&#13;
        creationBlock = uint64(block.number);&#13;
        // add a rough prediction of what block is the starting block&#13;
        startingBlockAround = uint64((startTime - block.timestamp) / 15 + block.number);&#13;
&#13;
        if (flags[F_TESTING]) {&#13;
            testMode = true;&#13;
            TestingEnabled();&#13;
        }&#13;
&#13;
        CreatedBallot(msg.sender, [startTime, endTime], useEncryption, specHash);&#13;
    }&#13;
&#13;
    // Ballot submission&#13;
    function submitBallotWithPk(bytes32 encryptedBallot, bytes32 senderPubkey) isTrue(useEncryption) ballotOpen public {&#13;
        addBallotAndVoterWithPk(encryptedBallot, senderPubkey);&#13;
        SuccessfulPkVote(msg.sender, encryptedBallot, senderPubkey);&#13;
    }&#13;
&#13;
    function submitBallotNoPk(bytes32 ballot) isFalse(useEncryption) ballotOpen public {&#13;
        addBallotAndVoterNoPk(ballot);&#13;
        SuccessfulVote(msg.sender, ballot);&#13;
    }&#13;
&#13;
    // Internal function to ensure atomicity of voter log&#13;
    function addBallotAndVoterWithPk(bytes32 encryptedBallot, bytes32 senderPubkey) internal {&#13;
        uint256 ballotNumber = addBallotAndVoterNoPk(encryptedBallot);&#13;
        associatedPubkeys[ballotNumber] = senderPubkey;&#13;
    }&#13;
&#13;
    function addBallotAndVoterNoPk(bytes32 encryptedBallot) internal returns (uint256) {&#13;
        uint256 ballotNumber = nVotesCast;&#13;
        ballotMap[ballotNumber] = Ballot(encryptedBallot, msg.sender, uint32(block.number));&#13;
        voterToBallotID[msg.sender] = ballotNumber;&#13;
        nVotesCast += 1;&#13;
        return ballotNumber;&#13;
    }&#13;
&#13;
    // Allow the owner to reveal the secret key after ballot conclusion&#13;
    function revealSeckey(bytes32 _secKey) onlyOwner public {&#13;
        require(block.timestamp &gt; endTime);&#13;
&#13;
        ballotEncryptionSeckey = _secKey;&#13;
        seckeyRevealed = true; // this flag allows the contract to be locked&#13;
        SeckeyRevealed(_secKey);&#13;
    }&#13;
&#13;
    function getEncSeckey() public constant returns (bytes32) {&#13;
        return ballotEncryptionSeckey;&#13;
    }&#13;
&#13;
    // Test functions&#13;
    function setEndTime(uint64 newEndTime) onlyTesting onlyOwner public {&#13;
        endTime = newEndTime;&#13;
    }&#13;
&#13;
    function setDeprecated() onlyOwner public {&#13;
        deprecated = true;&#13;
        DeprecatedContract();&#13;
    }&#13;
&#13;
    function setOwner(address newOwner) onlyOwner public {&#13;
        owner = newOwner;&#13;
        SetOwner(newOwner);&#13;
    }&#13;
&#13;
    // utils&#13;
    function max(uint64 a, uint64 b) pure internal returns(uint64) {&#13;
        if (a &gt; b) {&#13;
            return a;&#13;
        }&#13;
        return b;&#13;
    }&#13;
}&#13;
&#13;
&#13;
//&#13;
// The Index by which democracies and ballots are tracked (and optionally deployed).&#13;
// Author: Max Kaye &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="bad7dbc2fac9dfd9cfc8df94ccd5cedf">[email protected]</a>&gt;&#13;
// (c) SecureVote 2018&#13;
//&#13;
&#13;
contract SVLightIndexShim {&#13;
&#13;
    address public owner;&#13;
&#13;
    struct Ballot {&#13;
        bytes32 specHash;&#13;
        bytes32 extraData;&#13;
        address votingContract;&#13;
        uint64 startTs;&#13;
    }&#13;
&#13;
    struct Democ {&#13;
        string name;&#13;
        address admin;&#13;
        Ballot[] ballots;&#13;
    }&#13;
&#13;
    mapping (bytes32 =&gt; Democ) public democs;&#13;
    bytes32[] public democList;&#13;
&#13;
    bool public paymentEnabled = false;&#13;
&#13;
    SVLightIndexShim prevIndex;&#13;
&#13;
    //* EVENTS /&#13;
&#13;
    event PaymentMade(uint128[2] valAndRemainder);&#13;
    event DemocInit(string name, bytes32 democHash, address admin);&#13;
    event BallotInit(bytes32 specHash, uint64[2] openPeriod, bool[2] flags);&#13;
    event BallotAdded(bytes32 democHash, bytes32 specHash, bytes32 extraData, address votingContract);&#13;
    event SetFees(uint128[2] _newFees);&#13;
    event PaymentEnabled(bool _feeEnabled);&#13;
&#13;
    //* MODIFIERS /&#13;
&#13;
    modifier onlyBy(address _account) {&#13;
        require(msg.sender == _account);&#13;
        _;&#13;
    }&#13;
&#13;
    //* FUNCTIONS /&#13;
&#13;
&#13;
    // constructor&#13;
    constructor(SVLightIndexShim _prevIndex) public {&#13;
        owner = msg.sender;&#13;
        prevIndex = _prevIndex;&#13;
&#13;
        bytes32 democHash;&#13;
        bytes32 specHash;&#13;
        bytes32 extraData;&#13;
        address votingContract;&#13;
        uint64 startTime;&#13;
&#13;
        for (uint i = 0; i &lt; prevIndex.nDemocs(); i++) {&#13;
            democHash = prevIndex.democList(i);&#13;
            democList.push(democHash);&#13;
            // only democracies are SWM&#13;
            democs[democHash].admin = msg.sender;&#13;
&#13;
            for (uint j = 0; j &lt; prevIndex.nBallots(democHash); j++) {&#13;
                (specHash, extraData, votingContract, startTime) = prevIndex.getNthBallot(democHash, j);&#13;
                democs[democHash].ballots.push(Ballot(specHash, extraData, votingContract, startTime));&#13;
            }&#13;
        }&#13;
    }&#13;
&#13;
    //* GLOBAL INFO */&#13;
&#13;
    function nDemocs() public constant returns (uint256) {&#13;
        return democList.length;&#13;
    }&#13;
&#13;
    //* PAYMENT AND OWNER FUNCTIONS */&#13;
&#13;
    function setOwner(address _owner) onlyBy(owner) public {&#13;
        owner = _owner;&#13;
    }&#13;
&#13;
    function setDemocAdminEmergency(bytes32 democHash, address newAdmin) onlyBy(owner) public {&#13;
        democs[democHash].admin = newAdmin;&#13;
    }&#13;
&#13;
    //* DEMOCRACY FUNCTIONS - INDIVIDUAL */&#13;
&#13;
    function getDemocInfo(bytes32 democHash) public constant returns (string name, address admin, uint256 nBallots) {&#13;
        // only democs are SWM Gov democs&#13;
        return ("SWM Governance", democs[democHash].admin, democs[democHash].ballots.length);&#13;
    }&#13;
&#13;
    function setAdmin(bytes32 democHash, address newAdmin) onlyBy(democs[democHash].admin) public {&#13;
        democs[democHash].admin = newAdmin;&#13;
    }&#13;
&#13;
    function nBallots(bytes32 democHash) public constant returns (uint256) {&#13;
        return democs[democHash].ballots.length;&#13;
    }&#13;
&#13;
    function getNthBallot(bytes32 democHash, uint256 n) public constant returns (bytes32 specHash, bytes32 extraData, address votingContract, uint64 startTime) {&#13;
        return (democs[democHash].ballots[n].specHash, democs[democHash].ballots[n].extraData, democs[democHash].ballots[n].votingContract, democs[democHash].ballots[n].startTs);&#13;
    }&#13;
&#13;
    //* ADD BALLOT TO RECORD */&#13;
&#13;
    function _commitBallot(bytes32 democHash, bytes32 specHash, bytes32 extraData, address votingContract, uint64 startTs) internal {&#13;
        democs[democHash].ballots.push(Ballot(specHash, extraData, votingContract, startTs));&#13;
        BallotAdded(democHash, specHash, extraData, votingContract);&#13;
    }&#13;
&#13;
    function addBallot(bytes32 democHash, bytes32 extraData, address votingContract)&#13;
                      onlyBy(democs[democHash].admin)&#13;
                      public&#13;
                      {&#13;
        SVLightBallotBox bb = SVLightBallotBox(votingContract);&#13;
        bytes32 specHash = bb.specHash();&#13;
        uint64 startTs = bb.startTime();&#13;
        _commitBallot(democHash, specHash, extraData, votingContract, startTs);&#13;
    }&#13;
&#13;
    function deployBallot(bytes32 democHash, bytes32 specHash, bytes32 extraData,&#13;
                          uint64[2] openPeriod, bool[2] flags)&#13;
                          onlyBy(democs[democHash].admin)&#13;
                          public payable {&#13;
        // the start time is max(startTime, block.timestamp) to avoid a DoS whereby a malicious electioneer could disenfranchise&#13;
        // token holders who have recently acquired tokens.&#13;
        uint64 startTs = max(openPeriod[0], uint64(block.timestamp));&#13;
        SVLightBallotBox votingContract = new SVLightBallotBox(specHash, [startTs, openPeriod[1]], flags);&#13;
        votingContract.setOwner(msg.sender);&#13;
        _commitBallot(democHash, specHash, extraData, address(votingContract), startTs);&#13;
        BallotInit(specHash, [startTs, openPeriod[1]], flags);&#13;
    }&#13;
&#13;
    // utils&#13;
    function max(uint64 a, uint64 b) pure internal returns(uint64) {&#13;
        if (a &gt; b) {&#13;
            return a;&#13;
        }&#13;
        return b;&#13;
    }&#13;
}