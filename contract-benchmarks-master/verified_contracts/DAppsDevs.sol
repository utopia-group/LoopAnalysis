pragma solidity ^0.4.23;

contract DAppsDevs {
    address public owner;

    string public constant companyName = "DApps Devs LLC";
    string public constant companySite = "dappsdevs.io, dappsdevs.com";
    string public constant phoneNumber  = "+1-302-481-9195";
    string public constant email = "<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="e78e898188a7838697979483829194c984888a">[email protected]</a>";&#13;
&#13;
    mapping(bytes32 =&gt; string) public additionalInfo;&#13;
&#13;
    constructor() public {&#13;
        owner = msg.sender;&#13;
    }&#13;
&#13;
    function () payable fromOwner() {&#13;
    }&#13;
&#13;
    function setCompanyInfo(bytes32 key, string value) fromOwner() public {&#13;
        additionalInfo[key] = value;&#13;
    }&#13;
&#13;
    function getCompanyInfo(bytes32 key) constant public returns (string) {&#13;
        return additionalInfo[key];&#13;
    }&#13;
&#13;
    function kill() fromOwner() public {&#13;
        selfdestruct(owner);&#13;
    }&#13;
&#13;
    modifier fromOwner() {&#13;
        require(owner == msg.sender);&#13;
        _;&#13;
    }&#13;
}