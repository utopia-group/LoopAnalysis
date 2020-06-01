pragma solidity ^0.4.15;

// Math helper functions
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}


/// @title DNNToken contract - Main DNN contract
/// @author Dondrey Taylor - <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="f69299989284938fb6929898d89b93929f97">[email protected]</a>&gt;&#13;
contract DNNToken {&#13;
    enum DNNSupplyAllocations {&#13;
        EarlyBackerSupplyAllocation,&#13;
        PRETDESupplyAllocation,&#13;
        TDESupplyAllocation,&#13;
        BountySupplyAllocation,&#13;
        WriterAccountSupplyAllocation,&#13;
        AdvisorySupplyAllocation,&#13;
        PlatformSupplyAllocation&#13;
    }&#13;
    function balanceOf(address who) constant public returns (uint256);&#13;
    function issueTokens(address, uint256, DNNSupplyAllocations) public pure returns (bool) {}&#13;
}&#13;
&#13;
/// @author Dondrey Taylor - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="771318191305120e37131919591a12131e16">[email protected]</a>&gt;&#13;
contract DNNAdvisoryLockBox {&#13;
&#13;
  using SafeMath for uint256;&#13;
&#13;
  // DNN Token Contract&#13;
  DNNToken public dnnToken;&#13;
&#13;
  // Addresses of the co-founders of DNN&#13;
  address public cofounderA;&#13;
  address public cofounderB;&#13;
&#13;
  // Amount of tokens that each advisor is entitled to&#13;
  mapping(address =&gt; uint256) advisorsWithEntitledSupply;&#13;
&#13;
  // Amount of tokens that each advisor is entitled to&#13;
	mapping(address =&gt; uint256) advisorsTokensIssued;&#13;
&#13;
  // The last time that tokens were issued to each advisor&#13;
	mapping(address =&gt; uint256) advisorsTokensIssuedOn;&#13;
&#13;
  // Events&#13;
	event AdvisorTokensSent(address to, uint256 issued, uint256 remaining);&#13;
	event AdvisorAdded(address advisor);&#13;
	event AdvisorAddressChanged(address oldaddress, address newaddress);&#13;
  event NotWhitelisted(address to);&#13;
  event NoTokensRemaining(address advisor);&#13;
  event NextRedemption(uint256 nextTime);&#13;
&#13;
  // Checks to see if sender is a cofounder&#13;
  modifier onlyCofounders() {&#13;
      require (msg.sender == cofounderA || msg.sender == cofounderB);&#13;
      _;&#13;
  }&#13;
&#13;
  // Replace advisor address&#13;
  function replaceAdvisorAddress(address oldaddress, address newaddress) public onlyCofounders {&#13;
      // Check to see if the advisor's old address exists&#13;
      if (advisorsWithEntitledSupply[oldaddress] &gt; 0) {&#13;
          advisorsWithEntitledSupply[newaddress] = advisorsWithEntitledSupply[oldaddress];&#13;
          advisorsWithEntitledSupply[oldaddress] = 0;&#13;
          emit AdvisorAddressChanged(oldaddress, newaddress);&#13;
      }&#13;
      else {&#13;
          emit NotWhitelisted(oldaddress);&#13;
      }&#13;
  }&#13;
&#13;
  // Provides the remaining amount tokens to be issued to the advisor&#13;
  function nextRedemptionTime(address advisorAddress) public view returns (uint256) {&#13;
      return advisorsTokensIssuedOn[advisorAddress] == 0 ? now : (advisorsTokensIssuedOn[advisorAddress] + 30 days);&#13;
  }&#13;
&#13;
  // Provides the remaining amount tokens to be issued to the advisor&#13;
  function checkRemainingTokens(address advisorAddress) public view returns (uint256) {&#13;
      return advisorsWithEntitledSupply[advisorAddress] - advisorsTokensIssued[advisorAddress];&#13;
  }&#13;
&#13;
  // Checks if the specified address is whitelisted&#13;
  function isWhitelisted(address advisorAddress) public view returns (bool) {&#13;
     return advisorsWithEntitledSupply[advisorAddress] != 0;&#13;
  }&#13;
&#13;
  // Add advisor address&#13;
  function addAdvisor(address advisorAddress, uint256 entitledTokenAmount) public onlyCofounders {&#13;
      advisorsWithEntitledSupply[advisorAddress] = entitledTokenAmount;&#13;
      emit AdvisorAdded(advisorAddress);&#13;
  }&#13;
&#13;
  // Amount of tokens that the advisor is entitled to&#13;
  function advisorEntitlement(address advisorAddress) public view returns (uint256) {&#13;
      return advisorsWithEntitledSupply[advisorAddress];&#13;
  }&#13;
&#13;
  constructor() public&#13;
  {&#13;
      // Set token address&#13;
      dnnToken = DNNToken(0x9D9832d1beb29CC949d75D61415FD00279f84Dc2);&#13;
&#13;
      // Set cofounder addresses&#13;
      cofounderA = 0x3Cf26a9FE33C219dB87c2e50572e50803eFb2981;&#13;
      cofounderB = 0x9FFE2aD5D76954C7C25be0cEE30795279c4Cab9f;&#13;
  }&#13;
&#13;
	// Handles incoming transactions&#13;
	function () public payable {&#13;
&#13;
      // Check to see if the advisor is within&#13;
      // our whitelist&#13;
      if (advisorsWithEntitledSupply[msg.sender] &gt; 0) {&#13;
&#13;
          // Check to see if the advisor has any tokens left&#13;
          if (advisorsTokensIssued[msg.sender] &lt; advisorsWithEntitledSupply[msg.sender]) {&#13;
&#13;
              // Check to see if we can issue tokens to them. Advisors can redeem every 30 days for 10 months&#13;
              if (advisorsTokensIssuedOn[msg.sender] == 0 || ((now - advisorsTokensIssuedOn[msg.sender]) &gt;= 30 days)) {&#13;
&#13;
                  // Issue tokens to advisors&#13;
                  uint256 tokensToIssue = advisorsWithEntitledSupply[msg.sender].div(10);&#13;
&#13;
                  // Update amount of tokens issued to this advisor&#13;
                  advisorsTokensIssued[msg.sender] = advisorsTokensIssued[msg.sender].add(tokensToIssue);&#13;
&#13;
                  // Update the time that we last issued tokens to this advisor&#13;
                  advisorsTokensIssuedOn[msg.sender] = now;&#13;
&#13;
                  // Allocation type will be advisory&#13;
                  DNNToken.DNNSupplyAllocations allocationType = DNNToken.DNNSupplyAllocations.AdvisorySupplyAllocation;&#13;
&#13;
                  // Attempt to issue tokens&#13;
                  if (!dnnToken.issueTokens(msg.sender, tokensToIssue, allocationType)) {&#13;
                      revert();&#13;
                  }&#13;
                  else {&#13;
                     emit AdvisorTokensSent(msg.sender, tokensToIssue, checkRemainingTokens(msg.sender));&#13;
                  }&#13;
              }&#13;
              else {&#13;
                   emit NextRedemption(advisorsTokensIssuedOn[msg.sender] + 30 days);&#13;
              }&#13;
          }&#13;
          else {&#13;
            emit NoTokensRemaining(msg.sender);&#13;
          }&#13;
      }&#13;
      else {&#13;
        emit NotWhitelisted(msg.sender);&#13;
      }&#13;
	}&#13;
&#13;
}