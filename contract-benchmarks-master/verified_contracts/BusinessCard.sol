pragma solidity ^0.4.24;

contract BusinessCard {
    
    address public jeremySchroeder;
    
    string public email;
    string public website;
    string public github;
    string public twitter;
    
    constructor () public {
        jeremySchroeder = msg.sender;
        email = '<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="107a7562757d693e637378627f757475625060627f647f7e7d71797c3e7378">[email protected]</a>';&#13;
        website = 'https://spudz.org';&#13;
        github = 'https://github.com/spdz';&#13;
        twitter = 'https://twitter.com/_spdz';&#13;
    }&#13;
}