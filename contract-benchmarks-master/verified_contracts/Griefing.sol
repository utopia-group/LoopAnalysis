/**
 *  @title Griefing
 *  @author Clément Lesaege - <<span class="__cf_email__" data-cfemail="56353a333b333822163a3325373331337835393b">[email protected]</span>&gt;&#13;
 *  This is a contract to illustrate griefing opportunities.&#13;
 *  If someone sends griefCost to the contract, the ether in it will be burnt.&#13;
 *  The owner can get the ether back if no one burnt his ethers.&#13;
 */&#13;
pragma solidity ^0.4.18;&#13;
&#13;
contract Griefing {&#13;
    uint public griefCost;&#13;
    address public owner;&#13;
    &#13;
    /** @dev Constructor.&#13;
     *  @param _griefCost The amount the griefer have to pay to destroy the ethers in the contract.&#13;
     */&#13;
    function Griefing(uint _griefCost) public payable {&#13;
        griefCost=_griefCost;&#13;
        owner=msg.sender;&#13;
    }&#13;
    &#13;
    /** @dev Pay griefCost in order to burn the ethers inside the contract.&#13;
     */&#13;
    function () public payable {&#13;
        require(msg.value==griefCost);&#13;
        address(0x0).send(this.balance);&#13;
    }&#13;
    &#13;
    /** @dev Get your ethers back (if no one has paid the griefCost).&#13;
     */&#13;
    function getBack() public {&#13;
        require(msg.sender==owner);&#13;
        msg.sender.send(this.balance);&#13;
    }&#13;
    &#13;
}