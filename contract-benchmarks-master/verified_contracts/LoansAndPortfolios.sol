pragma solidity ^0.4.24;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, reverts on overflow.
  */
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (_a == 0) {
      return 0;
    }

    uint256 c = _a * _b;
    require(c / _a == _b);

    return c;
  }

  /**
  * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
  */
  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    require(_b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = _a / _b;
    // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold

    return c;
  }

  /**
  * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    require(_b <= _a);
    uint256 c = _a - _b;

    return c;
  }

  /**
  * @dev Adds two numbers, reverts on overflow.
  */
  function add(uint256 _a, uint256 _b) internal pure returns (uint256) {
    uint256 c = _a + _b;
    require(c >= _a);

    return c;
  }

  /**
  * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
  * reverts when dividing by zero.
  */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}
// by <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="38545d59565c4a57164a594f515b42785b5751565e595a4a5153165b5755">[email protected]</a>  for the consensys course&#13;
&#13;
&#13;
/*&#13;
function call order :&#13;
&#13;
constructor() &#13;
function addBank(address _addressBank, uint256 _tokens) IsOwner public&#13;
function addTokensToBank(address _bank, uint256 _tokens) IsOwner public&#13;
function GetBankBalance() isBank public view returns (uint256)&#13;
function removeBankToken(uint256 _value) isBank public&#13;
function ChangeInterest(uint256 _installment, uint256 _value, uint256 _category, bool _enable) isBank public&#13;
function findOutInterestByBank(uint256 _category, uint256 _amount, uint256 _installment) isBank public view returns(uint256 _value, bool _enable)&#13;
function addClient (address _addressUser, uint256 _category) IsOwner  public    &#13;
function ChangeClientCategory (address _client, uint256 _category) IsOwner public&#13;
function GetClientCategory()  isClient public view returns(uint256)&#13;
function GetClientCategory(address _client) isBank public view returns(uint256)&#13;
&#13;
function findOutInterestByClientCategory(address _bankAddress, uint256 _amount, uint256 _installment) isClient public view returns(uint256 _value, bool _enable)&#13;
function askForALoan(address _bankAddress, uint256 _amount, uint256 _installment) isClient public&#13;
function GetLoansLenght(bool _pending) public isBank view returns (uint256) {&#13;
function GetLoanInfo(uint256 _indexLoan, bool _pending)  public view returns(uint256 _debt, address _client, uint256 _installment, uint256 _category , uint256 _amount, address _owner, uint256 _forSale){&#13;
function aproveLoan(uint256 _loanIndex) public isBank&#13;
function getLoanIDbyClient(uint256 _indexLoan) isClient public view returns (uint256){&#13;
function getLoansLengthByClient() isClient public view returns(uint256){&#13;
function SellLoan(uint256 _indexLoan, uint256 _value) isLoanOwner(_indexLoan)  public &#13;
function BuyLoan(address _owner, uint256 _loanId, uint256 _value)  isBank public&#13;
function payOffClientDebt(uint256 _loanId, uint256 _value)  isLoanOwner(_loanId) public&#13;
function GetClientBalance() isClient public view returns (uint256 _value)&#13;
function removeClientToken(uint256 _value) isClient public&#13;
&#13;
&#13;
&#13;
// Portfolios&#13;
function createPortfolio(uint256 _idLoan) isBank public  returns (uint256 _index)  &#13;
function countPortfolios(address _bankAddress) isBank public view returns (uint256 _result&#13;
function addLoanToPortfolio(uint256 _indexPortfolio, uint256 _idLoan) isOwnerPortfolio (_indexPortfolio) public returns (bool _result)&#13;
function GetLoanIdFromPortfolio(uint256 _indexPortfolio, uint256 _indexLoan)  isBank public view returns(uint256 _ID){&#13;
function getPortfolioInfo (address _bankAddress, uint256 _indexPortfolio) isBank  public view returns (uint256 _LoansLength, uint256 _forSale, address _owner){&#13;
function removeLoanFromPortfolio(uint256 _indexPortfolio, uint256 _idLoan) isOwnerPortfolio (_indexPortfolio) public returns (bool _result)&#13;
function deletePortfolio(uint256 _indexPortfolio) isOwnerPortfolio(_indexPortfolio) public&#13;
function sellPorftolio(uint256 _indexPortfolio, uint256 _value) isOwnerPortfolio (_indexPortfolio) public &#13;
function buyPortfolio(address _owner, uint256 _indexPortfolio, uint256 _value) isBank public &#13;
&#13;
*/&#13;
&#13;
&#13;
&#13;
&#13;
&#13;
contract Base {&#13;
&#13;
    using SafeMath for uint256;&#13;
    address public owner;&#13;
    &#13;
    struct Client {&#13;
        uint256 Tokens;&#13;
        address Owner;&#13;
        uint256 Category;&#13;
        uint256[] LoansID;&#13;
    }&#13;
    struct Bank {&#13;
        uint256 Tokens;&#13;
        address Owner;&#13;
     &#13;
        mapping (uint256=&gt;strCateg) Category;&#13;
        uint256[] LoansID;&#13;
        Loan[] LoanPending;&#13;
        Portfolio[] Portfolios;&#13;
    }&#13;
    struct strCateg{&#13;
        mapping(uint256=&gt;strAmount) Amount;&#13;
    }&#13;
    struct strAmount{&#13;
        mapping(uint256=&gt;strInsta) Installment;&#13;
    }&#13;
    struct strInsta{&#13;
        uint256 value;&#13;
        bool enable;&#13;
    }&#13;
    struct Loan{&#13;
            uint256 Debt;&#13;
&#13;
            uint256 Installment;&#13;
            uint256 Id;&#13;
            uint256 ForSale;&#13;
            address Client;&#13;
            address Owner;&#13;
            uint256 Category;&#13;
            uint256 Amount;&#13;
            uint256 StartTime;&#13;
            uint256 EndTime;&#13;
    }&#13;
    struct Portfolio{&#13;
        uint256[] idLoans;&#13;
        address Owner;&#13;
        uint256 forSale;&#13;
    }&#13;
    &#13;
    mapping(address =&gt; Client) clients;&#13;
    mapping(address =&gt; Bank) banks;&#13;
    Loan[] loans;&#13;
    &#13;
    function () public payable{&#13;
        require(false, "Should not go through this point");&#13;
    }&#13;
&#13;
 &#13;
}&#13;
contract ClientFunctions is Base{&#13;
    modifier isClient(){&#13;
        require(clients[msg.sender].Owner == msg.sender, "not a client");&#13;
        _;&#13;
    }&#13;
    function askForALoan(address _bankAddress, uint256 _amount, uint256 _installment) isClient public  {&#13;
        &#13;
        require(banks[_bankAddress].Owner==_bankAddress, "not a valid bank");&#13;
        require(banks[_bankAddress].Category[clients[msg.sender].Category].Amount[_amount].Installment[_installment].enable, "you not apply for that loan");&#13;
&#13;
        Loan memory _loan;&#13;
        _loan.Debt = _amount;&#13;
        _loan.Debt  = _loan.Debt.add(banks[_bankAddress].Category[clients[msg.sender].Category].Amount[_amount].Installment[_installment].value);&#13;
        &#13;
        _loan.Client = msg.sender;&#13;
        _loan.Owner = _bankAddress;&#13;
        _loan.Installment = _installment;&#13;
        _loan.Category = clients[msg.sender].Category;&#13;
        _loan.Amount = _amount;&#13;
        &#13;
        banks[_bankAddress].LoanPending.push(_loan);&#13;
        &#13;
        &#13;
&#13;
    }&#13;
    &#13;
    function findOutInterestByClientCategory(address _bankAddress, uint256 _amount, uint256 _installment) isClient public view returns(uint256 _value, bool _enable){&#13;
        _value = banks[_bankAddress].Category[clients[msg.sender].Category].Amount[_amount].Installment[_installment].value;&#13;
        _enable = banks[_bankAddress].Category[clients[msg.sender].Category].Amount[_amount].Installment[_installment].enable;&#13;
    }&#13;
    function removeClientToken(uint256 _value) isClient public{&#13;
        require(clients[msg.sender].Tokens &gt;= _value, "You don't have that many tokens");&#13;
        clients[msg.sender].Tokens = clients[msg.sender].Tokens.sub(_value);&#13;
    }&#13;
    function getClientBalance() isClient public view returns (uint256 _value){&#13;
        _value = clients[msg.sender].Tokens;&#13;
    }&#13;
    &#13;
&#13;
    function getLoansLengthByClient() isClient public view returns(uint256){&#13;
        return clients[msg.sender].LoansID.length;&#13;
    }&#13;
    function getLoanIDbyClient(uint256 _indexLoan) isClient public view returns (uint256){&#13;
        return clients[msg.sender].LoansID[_indexLoan];&#13;
    }&#13;
    function getClientCategory() isClient public view returns(uint256){&#13;
&#13;
        return clients[msg.sender].Category;&#13;
    } &#13;
}&#13;
contract BankFunctions is ClientFunctions{&#13;
    modifier isBank(){&#13;
        require(banks[msg.sender].Owner==msg.sender, "you are not a bank");&#13;
        _;&#13;
    }&#13;
    modifier isLoanOwner(uint256 _id) {&#13;
        require(banks[msg.sender].Owner==msg.sender, "you are not a bank");&#13;
        require(loans[_id].Owner == msg.sender, "not owner of loan");&#13;
        _;&#13;
    }&#13;
    &#13;
    function GetClientCategory(address _client) isBank public view returns(uint256){&#13;
&#13;
        return clients[_client].Category;&#13;
    } &#13;
    &#13;
    function removeBankToken(uint256 _value) isBank public{&#13;
        require(banks[msg.sender].Tokens &gt;= _value, "You don't have that many tokens");&#13;
        banks[msg.sender].Tokens = banks[msg.sender].Tokens.sub(_value);&#13;
    }&#13;
    function payOffClientDebt(uint256 _loanId, uint256 _value)  isLoanOwner(_loanId) public{&#13;
&#13;
        require(loans[_loanId].Debt &gt; 0);&#13;
        require(_value &gt; 0);&#13;
        require(loans[_loanId].Debt&gt;= _value);&#13;
        loans[loans.length-1].EndTime = now;&#13;
        loans[_loanId].Debt = loans[_loanId].Debt.sub(_value);&#13;
    &#13;
&#13;
    }&#13;
    &#13;
    function ChangeInterest(uint256 _category, uint256 _amount, uint256 _installment, uint256 _value, bool _enable) isBank public{&#13;
        banks[msg.sender].Category[_category].Amount[_amount].Installment[_installment].value = _value;&#13;
        banks[msg.sender].Category[_category].Amount[_amount].Installment[_installment].enable = _enable;&#13;
    }&#13;
    function GetBankBalance() isBank public view returns (uint256 ){&#13;
        return banks[msg.sender].Tokens;&#13;
    }&#13;
    function findOutInterestByBank(uint256 _category, uint256 _amount, uint256 _installment) isBank public view returns(uint256 _value, bool _enable){&#13;
        _value = banks[msg.sender].Category[_category].Amount[_amount].Installment[_installment].value;&#13;
        _enable = banks[msg.sender].Category[_category].Amount[_amount].Installment[_installment].enable;&#13;
    }&#13;
&#13;
    &#13;
}&#13;
contract LoansFunctions is BankFunctions{&#13;
&#13;
    &#13;
    function SellLoan(uint256 _loanId, uint256 _value) isLoanOwner(_loanId)  public {&#13;
        loans[_loanId].ForSale = _value;&#13;
    }&#13;
    &#13;
    function BuyLoan(address _owner, uint256 _loanId, uint256 _value)  isBank public{&#13;
        require(loans[_loanId].ForSale &gt; 0, "not for sale");&#13;
        require(banks[msg.sender].Tokens&gt;= _value, "you don't have money");&#13;
        SwitchLoanOwner( _owner,  _loanId);        &#13;
        &#13;
        &#13;
        banks[msg.sender].Tokens = banks[msg.sender].Tokens.sub(_value);&#13;
        banks[_owner].Tokens = banks[_owner].Tokens.add(_value);&#13;
    }&#13;
    &#13;
    &#13;
    function SwitchLoanOwner(address _owner, uint256 _loanId) internal{&#13;
        //requisitos&#13;
        require(loans[_loanId].Debt&gt; 0, "at least one of the loans is already paid");&#13;
        require(loans[_loanId].Owner == _owner);&#13;
        uint256 _indexLoan;&#13;
        for (uint256 i; i&lt;banks[_owner].LoansID.length; i++){&#13;
            if (banks[_owner].LoansID[i] == _loanId){&#13;
                _indexLoan = i;&#13;
                i =  banks[_owner].LoansID.length.add(1);&#13;
            }&#13;
        }&#13;
&#13;
&#13;
        // asignar Loan&#13;
        banks[msg.sender].LoansID.push(_loanId);&#13;
        &#13;
        if (_indexLoan !=banks[_owner].LoansID.length - 1){&#13;
                banks[_owner].LoansID[_indexLoan] = banks[_owner].LoansID[banks[_owner].LoansID.length - 1];         &#13;
        }&#13;
        &#13;
        delete banks[_owner].LoansID[banks[_owner].LoansID.length -1];&#13;
        banks[_owner].LoansID.length --;&#13;
        &#13;
        loans[_loanId].ForSale = 0;&#13;
        loans[_loanId].Owner = msg.sender;&#13;
        &#13;
        &#13;
        &#13;
    }&#13;
    &#13;
    function aproveLoan(uint256 _loanIndex) public {&#13;
        require(banks[msg.sender].LoanPending[_loanIndex].Owner == msg.sender, "you are not the owner");&#13;
        require(banks[msg.sender].Tokens&gt;=banks[msg.sender].LoanPending[_loanIndex].Amount, "the bank does not have that amount of tokens");&#13;
&#13;
        banks[msg.sender].LoanPending[_loanIndex].Id =loans.length;&#13;
        loans.push(banks[msg.sender].LoanPending[_loanIndex]);&#13;
        loans[loans.length-1].StartTime = now;&#13;
        address _client = banks[msg.sender].LoanPending[_loanIndex].Client;&#13;
        uint256 _amount  = banks[msg.sender].LoanPending[_loanIndex].Amount;&#13;
        &#13;
        banks[msg.sender].LoansID.push(loans.length - 1);&#13;
        clients[_client].LoansID.push(loans.length - 1);&#13;
        &#13;
        clients[_client].Tokens =  clients[_client].Tokens.add(_amount);&#13;
        banks[msg.sender].Tokens =  banks[msg.sender].Tokens.sub(_amount);&#13;
&#13;
        &#13;
        if(banks[msg.sender].LoanPending.length !=1){&#13;
            banks[msg.sender].LoanPending[_loanIndex] = banks[msg.sender].LoanPending [banks[msg.sender].LoanPending.length - 1];    &#13;
        }&#13;
&#13;
        delete banks[msg.sender].LoanPending [banks[msg.sender].LoanPending.length - 1];&#13;
        banks[msg.sender].LoanPending.length--;&#13;
&#13;
    }&#13;
    // in case of _pending = true,  the function will check the LoansPending &#13;
    function GetLoansLenght(bool _pending) public isBank view returns (uint256) {&#13;
        if (_pending){&#13;
            return banks[msg.sender].LoanPending.length;    &#13;
        }else{&#13;
            return banks[msg.sender].LoansID.length;&#13;
        }&#13;
        &#13;
    }&#13;
    function GetLoanInfo(uint256 _indexLoan, bool _pending)  public view returns(uint256 _debt, address _client, uint256 _installment, uint256 _category , uint256 _amount, address _owner, uint256 _forSale, uint256 _StartTime, uint256 _EndTime){&#13;
        &#13;
        Loan memory _loan;&#13;
        if (_pending){&#13;
            require (_indexLoan &lt; banks[msg.sender].LoanPending.length, "null value");&#13;
            _loan = banks[msg.sender].LoanPending[_indexLoan];&#13;
        }else{&#13;
            _loan = loans[_indexLoan];&#13;
        }&#13;
        &#13;
        _debt = _loan.Debt;&#13;
        _client =  _loan.Client;&#13;
        _installment =  _loan.Installment;&#13;
        _category = _loan.Category;&#13;
        _amount = _loan.Amount ;&#13;
        _owner = _loan.Owner ;&#13;
        _forSale = _loan.ForSale;&#13;
        _StartTime = _loan.StartTime;&#13;
        _EndTime = _loan.EndTime;&#13;
    }&#13;
&#13;
&#13;
    &#13;
}&#13;
contract PortfolioFunctions is LoansFunctions{&#13;
    modifier isOwnerPortfolio(uint256 _indexPortfolio)  {&#13;
        require(banks[msg.sender].Portfolios[_indexPortfolio].Owner== msg.sender, "not the owner of portfolio");&#13;
        _;&#13;
    }&#13;
    function createPortfolio(uint256 _idLoan) isBank public  returns (uint256 )  {&#13;
            require(msg.sender== loans[_idLoan].Owner);&#13;
            Portfolio  memory  _portfolio;&#13;
            banks[msg.sender].Portfolios.push(_portfolio);&#13;
            banks[msg.sender].Portfolios[banks[msg.sender].Portfolios.length-1].idLoans.push(_idLoan);&#13;
            banks[msg.sender].Portfolios[banks[msg.sender].Portfolios.length-1].Owner= msg.sender;&#13;
&#13;
            return banks[msg.sender].Portfolios.length-1;&#13;
    }&#13;
    function deletePortfolio(uint256 _indexPortfolio) isOwnerPortfolio(_indexPortfolio) public{&#13;
        uint256 _PortfolioLength = banks[msg.sender].Portfolios.length;&#13;
        banks[msg.sender].Portfolios[_indexPortfolio] = banks[msg.sender].Portfolios[_PortfolioLength -1];&#13;
        delete banks[msg.sender].Portfolios[_PortfolioLength -1];&#13;
        banks[msg.sender].Portfolios.length --;&#13;
        &#13;
    }&#13;
    function addLoanToPortfolio(uint256 _indexPortfolio, uint256 _idLoan) isOwnerPortfolio (_indexPortfolio) public {&#13;
        for(uint256 i; i&lt;banks[msg.sender].Portfolios[_indexPortfolio].idLoans.length;i++){&#13;
            if (banks[msg.sender].Portfolios[_indexPortfolio].idLoans[i]==_idLoan){&#13;
                require(false, "that loan already exists on the portfolio");&#13;
            }&#13;
        }&#13;
        banks[msg.sender].Portfolios[_indexPortfolio].idLoans.push(_idLoan);&#13;
    }&#13;
    &#13;
    function removeLoanFromPortfolio(uint256 _indexPortfolio, uint256 _idLoan) isOwnerPortfolio (_indexPortfolio) public returns (bool _result){&#13;
        &#13;
        uint256 Loanslength = banks[msg.sender].Portfolios[_indexPortfolio].idLoans.length;&#13;
        uint256 _loanIndex = Loanslength;&#13;
        for(uint256 i; i&lt;Loanslength; i++){&#13;
            if(_idLoan ==banks[msg.sender].Portfolios[_indexPortfolio].idLoans[i]){&#13;
                _loanIndex = i;&#13;
                i= Loanslength;&#13;
            }&#13;
        }&#13;
        require(_loanIndex&lt;Loanslength, "the loan is not in the portfolio");&#13;
        &#13;
        if (_loanIndex !=banks[msg.sender].Portfolios[_indexPortfolio].idLoans.length-1){&#13;
               banks[msg.sender].Portfolios[_indexPortfolio].idLoans[_loanIndex] = banks[msg.sender].Portfolios[_indexPortfolio].idLoans[Loanslength-1];&#13;
        }&#13;
        delete banks[msg.sender].Portfolios[_indexPortfolio].idLoans[Loanslength -1];&#13;
        banks[msg.sender].Portfolios[_indexPortfolio].idLoans.length --;&#13;
        &#13;
        if (banks[msg.sender].Portfolios[_indexPortfolio].idLoans.length == 0){&#13;
            deletePortfolio(_indexPortfolio);&#13;
        }&#13;
        _result = true;&#13;
    }    &#13;
    function getPortfolioInfo (address _bankAddress, uint256 _indexPortfolio) isBank  public view returns (uint256 _LoansLength, uint256 _forSale, address _owner){&#13;
        require(banks[_bankAddress].Portfolios[_indexPortfolio].Owner == _bankAddress, "not the owner of that portfolio");&#13;
        _LoansLength =    banks[_bankAddress].Portfolios[_indexPortfolio].idLoans.length;&#13;
        _forSale =    banks[_bankAddress].Portfolios[_indexPortfolio].forSale;&#13;
        _owner =    banks[_bankAddress].Portfolios[_indexPortfolio].Owner;&#13;
    }&#13;
    function sellPorftolio(uint256 _indexPortfolio, uint256 _value) isOwnerPortfolio (_indexPortfolio) public {&#13;
          require(banks[msg.sender].Portfolios[_indexPortfolio].idLoans.length&gt;0);&#13;
          banks[msg.sender].Portfolios[_indexPortfolio].forSale = _value;&#13;
    }&#13;
    function buyPortfolio(address _owner, uint256 _indexPortfolio, uint256 _value) isBank public {&#13;
        &#13;
        require(banks[msg.sender].Tokens&gt;=_value);&#13;
        require(banks[_owner].Portfolios[_indexPortfolio].idLoans.length &gt; 0);&#13;
        require(banks[_owner].Portfolios[_indexPortfolio].forSale &gt; 0);&#13;
        require(banks[_owner].Portfolios[_indexPortfolio].forSale == _value );&#13;
        &#13;
&#13;
        banks[msg.sender].Tokens = banks[msg.sender].Tokens.sub(_value);&#13;
        banks[_owner].Tokens = banks[_owner].Tokens.add(_value);&#13;
        &#13;
        for(uint256 a;a&lt; banks[_owner].Portfolios[_indexPortfolio].idLoans.length ;a++){&#13;
           SwitchLoanOwner(_owner,  banks[_owner].Portfolios[_indexPortfolio].idLoans[a]);&#13;
        }&#13;
        &#13;
        if (_indexPortfolio !=banks[_owner].Portfolios.length-1){&#13;
               banks[_owner].Portfolios[_indexPortfolio] = banks[_owner].Portfolios[banks[_owner].Portfolios.length-1];         &#13;
        }&#13;
        delete banks[_owner].Portfolios[banks[_owner].Portfolios.length -1];&#13;
        banks[_owner].Portfolios.length--;&#13;
    }&#13;
    function countPortfolios(address _bankAddress) isBank public view returns (uint256 _result){&#13;
        _result = banks[_bankAddress].Portfolios.length;&#13;
    }&#13;
    function GetLoanIdFromPortfolio(uint256 _indexPortfolio, uint256 _indexLoan)  isBank public view returns(uint256 _ID){&#13;
        return banks[msg.sender].Portfolios[_indexPortfolio].idLoans[_indexLoan];&#13;
    }&#13;
    &#13;
&#13;
    &#13;
}&#13;
contract GobernanceFunctions is PortfolioFunctions{&#13;
&#13;
    modifier IsOwner{&#13;
        require(owner == msg.sender, "not the owner");&#13;
        _;&#13;
    }&#13;
&#13;
    function addBank(address _addressBank, uint256 _tokens) IsOwner public{&#13;
        require(banks[_addressBank].Owner==0);&#13;
        require(clients[_addressBank].Owner == 0);&#13;
        banks[_addressBank].Owner=_addressBank;&#13;
        banks[_addressBank].Tokens =  _tokens;&#13;
&#13;
    }&#13;
    function addClient (address _addressClient, uint256 _category) IsOwner  public{&#13;
        require(banks[_addressClient].Owner!=_addressClient, "that addreess is a bank");&#13;
        require(clients[_addressClient].Owner!=_addressClient, "that client already exists");&#13;
        require (_category &gt; 0);&#13;
        clients[_addressClient].Owner = _addressClient;&#13;
        clients[_addressClient].Category =  _category; &#13;
        clients[_addressClient].Tokens =  0;&#13;
    }&#13;
    function addTokensToBank(address _bank, uint256 _tokens) IsOwner public{&#13;
        require(banks[_bank].Owner==_bank, "not a Bank");&#13;
        banks[_bank].Tokens = banks[_bank].Tokens.add(_tokens);&#13;
    }&#13;
    function changeClientCategory (address _client, uint256 _category) IsOwner public{&#13;
        require (clients[_client].Owner==_client, "not a client");&#13;
        clients[_client].Category = _category;&#13;
    &#13;
    }&#13;
}&#13;
&#13;
contract LoansAndPortfolios is GobernanceFunctions{&#13;
&#13;
    constructor() public {&#13;
        owner = msg.sender;&#13;
    }&#13;
&#13;
}