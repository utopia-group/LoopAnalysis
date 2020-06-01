pragma solidity ^0.4.17;

//
// ==== DISCLAIMER ====
//
// ETHEREUM IS STILL AN EXPEREMENTAL TECHNOLOGY.
// ALTHOUGH THIS SMART CONTRACT WAS CREATED WITH GREAT CARE AND IN THE HOPE OF BEING USEFUL, NO GUARANTEES OF FLAWLESS OPERATION CAN BE GIVEN.
// IN PARTICULAR - SUBTILE BUGS, HACKER ATTACKS OR MALFUNCTION OF UNDERLYING TECHNOLOGY CAN CAUSE UNINTENTIONAL BEHAVIOUR.
// YOU ARE STRONGLY ENCOURAGED TO STUDY THIS SMART CONTRACT CAREFULLY IN ORDER TO UNDERSTAND POSSIBLE EDGE CASES AND RISKS.
// DON'T USE THIS SMART CONTRACT IF YOU HAVE SUBSTANTIAL DOUBTS OR IF YOU DON'T KNOW WHAT YOU ARE DOING.
//
// THIS SOFTWARE IS PROVIDED "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
// AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA,
// OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
// ====
//
//
// ==== PARANOIA NOTICE ====
// A careful reader will find some additional checks and excessive code, consuming some extra gas. This is intentional.
// Even though the contract should work without these parts, they make the code more secure in production and for future refactoring.
// Also, they show more clearly what we have considered and addressed during development.
// Discussion is welcome!
// ====
//

/// @author ethernian
/// @notice report bugs to: <span class="__cf_email__" data-cfemail="6d0f180a1e2d081905081f03040c03430e0200">[email protected]</span>&#13;
/// @title BnsPresale Contract&#13;
&#13;
contract BnsPresale {&#13;
&#13;
    string public constant VERSION = "0.2.0-bns";&#13;
&#13;
    /* ====== configuration START ====== */&#13;
    uint public constant PRESALE_START  = 4470000; /* approx. WED NOV 01 2017 12:55:47 GMT+0100 (CET) */&#13;
    uint public constant PRESALE_END    = 5033333; /* approx. WED JAN 31 2018 19:39:39 GMT+0100 (CET) */&#13;
    uint public constant WITHDRAWAL_END = 5111111; /* approx. TUE FEB 13 2018 10:08:39 GMT+0100 (CET) */&#13;
&#13;
    address public constant OWNER = 0x54ef8Ffc6EcdA95d286722c0358ad79123c3c8B0;&#13;
&#13;
    uint public constant MIN_TOTAL_AMOUNT_TO_RECEIVE_ETH = 0;&#13;
    uint public constant MAX_TOTAL_AMOUNT_TO_RECEIVE_ETH = 3125;&#13;
    uint public constant MIN_ACCEPTED_AMOUNT_FINNEY = 1;&#13;
&#13;
    /* ====== configuration END ====== */&#13;
&#13;
    string[5] private stateNames = ["BEFORE_START",  "PRESALE_RUNNING", "WITHDRAWAL_RUNNING", "REFUND_RUNNING", "CLOSED" ];&#13;
    enum State { BEFORE_START,  PRESALE_RUNNING, WITHDRAWAL_RUNNING, REFUND_RUNNING, CLOSED }&#13;
&#13;
    uint public total_received_amount;&#13;
    uint public total_refunded;&#13;
    mapping (address =&gt; uint) public balances;&#13;
&#13;
    uint private constant MIN_TOTAL_AMOUNT_TO_RECEIVE = MIN_TOTAL_AMOUNT_TO_RECEIVE_ETH * 1 ether;&#13;
    uint private constant MAX_TOTAL_AMOUNT_TO_RECEIVE = MAX_TOTAL_AMOUNT_TO_RECEIVE_ETH * 1 ether;&#13;
    uint private constant MIN_ACCEPTED_AMOUNT = MIN_ACCEPTED_AMOUNT_FINNEY * 1 finney;&#13;
    bool public isAborted = false;&#13;
    bool public isStopped = false;&#13;
&#13;
&#13;
    //constructor&#13;
    function BnsPresale () public validSetupOnly() { }&#13;
&#13;
    //&#13;
    // ======= interface methods =======&#13;
    //&#13;
&#13;
    //accept payments here&#13;
    function ()&#13;
    payable&#13;
    noReentrancy&#13;
    public&#13;
    {&#13;
        State state = currentState();&#13;
        if (state == State.PRESALE_RUNNING) {&#13;
            receiveFunds();&#13;
        } else if (state == State.REFUND_RUNNING) {&#13;
            // any entring call in Refund Phase will cause full refund&#13;
            sendRefund();&#13;
        } else {&#13;
            revert();&#13;
        }&#13;
    }&#13;
&#13;
    function refund() external&#13;
    inState(State.REFUND_RUNNING)&#13;
    noReentrancy&#13;
    {&#13;
        sendRefund();&#13;
    }&#13;
&#13;
&#13;
    function withdrawFunds() external&#13;
    onlyOwner&#13;
    noReentrancy&#13;
    {&#13;
        // transfer funds to owner if any&#13;
        OWNER.transfer(this.balance);&#13;
    }&#13;
&#13;
&#13;
    function abort() external&#13;
    inStateBefore(State.REFUND_RUNNING)&#13;
    onlyOwner&#13;
    {&#13;
        isAborted = true;&#13;
    }&#13;
&#13;
&#13;
    function stop() external&#13;
    inState(State.PRESALE_RUNNING)&#13;
    onlyOwner&#13;
    {&#13;
        isStopped = true;&#13;
    }&#13;
&#13;
&#13;
    //displays current contract state in human readable form&#13;
    function state() external constant&#13;
    returns (string)&#13;
    {&#13;
        return stateNames[ uint(currentState()) ];&#13;
    }&#13;
&#13;
&#13;
    //&#13;
    // ======= implementation methods =======&#13;
    //&#13;
&#13;
    function sendRefund() private tokenHoldersOnly {&#13;
        // load balance to refund plus amount currently sent&#13;
        uint amount_to_refund = min(balances[msg.sender], this.balance - msg.value) ;&#13;
&#13;
        // change balance&#13;
        balances[msg.sender] -= amount_to_refund;&#13;
        total_refunded += amount_to_refund;&#13;
&#13;
        // send refund back to sender&#13;
        msg.sender.transfer(amount_to_refund + msg.value);&#13;
    }&#13;
&#13;
&#13;
    function receiveFunds() private notTooSmallAmountOnly {&#13;
      // no overflow is possible here: nobody have soo much money to spend.&#13;
      if (total_received_amount + msg.value &gt; MAX_TOTAL_AMOUNT_TO_RECEIVE) {&#13;
          // accept amount only and return change&#13;
          var change_to_return = total_received_amount + msg.value - MAX_TOTAL_AMOUNT_TO_RECEIVE;&#13;
          var acceptable_remainder = MAX_TOTAL_AMOUNT_TO_RECEIVE - total_received_amount;&#13;
          balances[msg.sender] += acceptable_remainder;&#13;
          total_received_amount += acceptable_remainder;&#13;
&#13;
          msg.sender.transfer(change_to_return);&#13;
      } else {&#13;
          // accept full amount&#13;
          balances[msg.sender] += msg.value;&#13;
          total_received_amount += msg.value;&#13;
      }&#13;
    }&#13;
&#13;
&#13;
    function currentState() private constant returns (State) {&#13;
        if (isAborted) {&#13;
            return this.balance &gt; 0&#13;
                   ? State.REFUND_RUNNING&#13;
                   : State.CLOSED;&#13;
        } else if (block.number &lt; PRESALE_START) {&#13;
            return State.BEFORE_START;&#13;
        } else if (block.number &lt;= PRESALE_END &amp;&amp; total_received_amount &lt; MAX_TOTAL_AMOUNT_TO_RECEIVE &amp;&amp; !isStopped) {&#13;
            return State.PRESALE_RUNNING;&#13;
        } else if (this.balance == 0) {&#13;
            return State.CLOSED;&#13;
        } else if (block.number &lt;= WITHDRAWAL_END &amp;&amp; total_received_amount &gt;= MIN_TOTAL_AMOUNT_TO_RECEIVE) {&#13;
            return State.WITHDRAWAL_RUNNING;&#13;
        } else {&#13;
            return State.REFUND_RUNNING;&#13;
        }&#13;
    }&#13;
&#13;
    function min(uint a, uint b) pure private returns (uint) {&#13;
        return a &lt; b ? a : b;&#13;
    }&#13;
&#13;
&#13;
    //&#13;
    // ============ modifiers ============&#13;
    //&#13;
&#13;
    //fails if state doesn't match&#13;
    modifier inState(State state) {&#13;
        assert(state == currentState());&#13;
        _;&#13;
    }&#13;
&#13;
    //fails if the current state is not before than the given one.&#13;
    modifier inStateBefore(State state) {&#13;
        assert(currentState() &lt; state);&#13;
        _;&#13;
    }&#13;
&#13;
&#13;
    //fails if something in setup is looking weird&#13;
    modifier validSetupOnly() {&#13;
        if ( OWNER == 0x0&#13;
            || PRESALE_START == 0&#13;
            || PRESALE_END == 0&#13;
            || WITHDRAWAL_END ==0&#13;
            || PRESALE_START &lt;= block.number&#13;
            || PRESALE_START &gt;= PRESALE_END&#13;
            || PRESALE_END   &gt;= WITHDRAWAL_END&#13;
            || MIN_TOTAL_AMOUNT_TO_RECEIVE &gt; MAX_TOTAL_AMOUNT_TO_RECEIVE )&#13;
                revert();&#13;
        _;&#13;
    }&#13;
&#13;
&#13;
    //accepts calls from owner only&#13;
    modifier onlyOwner(){&#13;
        assert(msg.sender == OWNER);&#13;
        _;&#13;
    }&#13;
&#13;
&#13;
    //accepts calls from token holders only&#13;
    modifier tokenHoldersOnly(){&#13;
        assert(balances[msg.sender] &gt; 0);&#13;
        _;&#13;
    }&#13;
&#13;
&#13;
    // don`t accept transactions with value less than allowed minimum&#13;
    modifier notTooSmallAmountOnly(){&#13;
        assert(msg.value &gt;= MIN_ACCEPTED_AMOUNT);&#13;
        _;&#13;
    }&#13;
&#13;
&#13;
    //prevents reentrancy attacs&#13;
    bool private locked = false;&#13;
    modifier noReentrancy() {&#13;
        assert(!locked);&#13;
        locked = true;&#13;
        _;&#13;
        locked = false;&#13;
    }&#13;
}//contract