pragma solidity ^0.4.25;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error.
 */
library SafeMath {
    // Multiplies two numbers, throws on overflow./
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) return 0;
        c = a * b;
        assert(c / a == b);
        return c;
    }
    // Integer division of two numbers, truncating the quotient.
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }
    // Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }
    // Adds two numbers, throws on overflow.
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }
}


/**
 * @title Smart-Mining 'team distribution'-contract - https://smart-mining.io - <span class="__cf_email__" data-cfemail="bad7dbd3d6fac9d7dbc8ce97d7d3d4d3d4dd94d3d5">[email protected]</span>&#13;
 */&#13;
contract SmartMining_Team {&#13;
    using SafeMath for uint256;&#13;
    &#13;
    // -------------------------------------------------------------------------&#13;
    // Variables&#13;
    // -------------------------------------------------------------------------&#13;
    &#13;
    struct Member {&#13;
        uint256 share;                            // Percent of mining profits&#13;
        uint256 unpaid;                           // Available Wei for withdrawal, + 1 in storage for gas optimization&#13;
    }                                              &#13;
    mapping (address =&gt; Member) private members;  // All contract members as 'Member'-struct&#13;
    &#13;
    uint16    public memberCount;                 // Count of all members&#13;
    address[] public memberIndex;                 // Lookuptable of all member addresses to iterate on deposit over and assign unpaid Ether to members&#13;
    address   public withdrawer;                  // Allowed executor of automatic processed member whitdrawals (SmartMining-API)&#13;
    address   public owner;                       // Owner of this contract&#13;
    &#13;
    &#13;
    // -------------------------------------------------------------------------&#13;
    // Private functions, can only be called by this contract&#13;
    // -------------------------------------------------------------------------&#13;
    &#13;
    function _addMember (address _member, uint256 _share) private {&#13;
        emit AddMember(_member, _share);&#13;
        members[_member].share = _share;&#13;
        members[_member].unpaid = 1;&#13;
        memberIndex.push(_member);&#13;
        memberCount++;&#13;
    }&#13;
    &#13;
    &#13;
    // -------------------------------------------------------------------------&#13;
    // Constructor&#13;
    // -------------------------------------------------------------------------&#13;
    &#13;
    constructor (address _owner) public {&#13;
        require(_owner != 0x0);&#13;
        &#13;
        // Initialize contract owner and trigger 'SetOwner'-event&#13;
        owner = _owner;&#13;
        emit SetOwner(owner);&#13;
        &#13;
        // Initialize withdrawer and trigger 'SetWithdrawer'-event&#13;
        withdrawer = msg.sender;&#13;
        emit SetWithdrawer(msg.sender);&#13;
        &#13;
        // Initialize members with their share (total 100) and trigger 'AddMember'-event&#13;
        _addMember(0xa440dC315E53d66a52828be147470f2A00Fc0cF4, 40);&#13;
        _addMember(0xE517CB63e4dD36533C26b1ffF5deB893E63c3afA, 40);&#13;
        _addMember(0x829381286b382E4597B02A69bAb5a74f73A1Ab75, 20);&#13;
    }&#13;
    &#13;
    &#13;
    // -------------------------------------------------------------------------&#13;
    // Events&#13;
    // -------------------------------------------------------------------------&#13;
    &#13;
    event SetOwner(address indexed owner);&#13;
    event SetWithdrawer(address indexed withdrawer);&#13;
    event AddMember(address indexed member, uint256 share);&#13;
    event Withdraw(address indexed member, uint256 value);&#13;
    event Deposit(address indexed from, uint256 value);&#13;
    &#13;
    &#13;
    // -------------------------------------------------------------------------&#13;
    // OWNER ONLY external maintenance interface&#13;
    // -------------------------------------------------------------------------&#13;
    &#13;
    modifier onlyOwner () {&#13;
        require(msg.sender == owner);&#13;
        _;&#13;
    }&#13;
    &#13;
    function setOwner (address _newOwner) external onlyOwner {&#13;
        if( _newOwner != 0x0 ) { owner = _newOwner; } else { owner = msg.sender; }&#13;
        emit SetOwner(owner);&#13;
    }&#13;
    &#13;
    function setWithdrawer (address _newWithdrawer) external onlyOwner {&#13;
        withdrawer = _newWithdrawer;&#13;
        emit SetWithdrawer(_newWithdrawer);&#13;
    }&#13;
    &#13;
    &#13;
    // -------------------------------------------------------------------------&#13;
    // Public external interface&#13;
    // -------------------------------------------------------------------------&#13;
    &#13;
    function () external payable {&#13;
        // Distribute deposited Ether to all members related to their profit-share&#13;
        for (uint i=0; i&lt;memberIndex.length; i++) {&#13;
            members[memberIndex[i]].unpaid = &#13;
                // Adding current deposit to members unpaid Wei amount&#13;
                members[memberIndex[i]].unpaid.add(&#13;
                    // MemberShare * DepositedWei / 100 = WeiAmount of member-share to be added to members unpaid holdings&#13;
                    members[memberIndex[i]].share.mul(msg.value).div(100)&#13;
                );&#13;
        }&#13;
        &#13;
        // Trigger 'Deposit'-event&#13;
        emit Deposit(msg.sender, msg.value);&#13;
    }&#13;
    &#13;
    function withdraw   ()                     external { _withdraw(msg.sender); }&#13;
    function withdrawOf (address _beneficiary) external { _withdraw(_beneficiary); }&#13;
    &#13;
    &#13;
    // -------------------------------------------------------------------------&#13;
    // Private functions, can only be called by this contract&#13;
    // -------------------------------------------------------------------------&#13;
    &#13;
    function _withdraw (address _beneficiary) private {&#13;
        // Pre-validate withdrawal&#13;
        if(msg.sender != _beneficiary) {&#13;
            require(msg.sender == owner || msg.sender == withdrawer, "Only 'owner' and 'withdrawer' can withdraw for other members.");&#13;
        }&#13;
        require(members[_beneficiary].unpaid &gt;= 1, "Not a member account.");&#13;
        require(members[_beneficiary].unpaid &gt; 1, "No unpaid balance on account.");&#13;
        &#13;
        // Remember members unpaid amount but remove it from his contract holdings before initiating the withdrawal for security reasons&#13;
        uint256 unpaid = members[_beneficiary].unpaid.sub(1);&#13;
        members[_beneficiary].unpaid = 1;&#13;
        &#13;
        // Trigger 'Withdraw'-event&#13;
        emit Withdraw(_beneficiary, unpaid);&#13;
        &#13;
        // Transfer the unpaid Wei amount to member address&#13;
        _beneficiary.transfer(unpaid);&#13;
    }&#13;
    &#13;
    function shareOf (address _member) public view returns (uint256) {&#13;
        // Get share percentage of member&#13;
        return members[_member].share;&#13;
    }&#13;
    &#13;
    function unpaidOf (address _member) public view returns (uint256) {&#13;
        // Get unpaid Wei amount of member&#13;
        return members[_member].unpaid.sub(1);&#13;
    }&#13;
    &#13;
    &#13;
}