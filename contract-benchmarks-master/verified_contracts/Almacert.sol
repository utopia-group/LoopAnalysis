pragma solidity ^0.4.24;

// Almacert v.1.0.8
// Universita' degli Studi di Cagliari
// http://www.unica.it
// @authors:
// Flosslab s.r.l. <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="aec7c0c8c1eec8c2c1ddddc2cfcc80cdc1c3">[email protected]</a>&gt;&#13;
&#13;
contract Almacert {&#13;
&#13;
    uint constant ID_LENGTH = 11;&#13;
    uint constant FCODE_LENGTH = 16;&#13;
    uint constant SESSION_LENGTH = 10;&#13;
&#13;
    modifier restricted() {&#13;
        require(msg.sender == owner);&#13;
        _;&#13;
    }&#13;
&#13;
    modifier restrictedToManager() {&#13;
        require(msg.sender == manager);&#13;
        _;&#13;
    }&#13;
&#13;
    struct Student {&#13;
        string fCode;&#13;
        string session;&#13;
        bytes32 hash;&#13;
    }&#13;
&#13;
    address private manager;&#13;
    address public owner;&#13;
&#13;
    mapping(string =&gt; Student) private student;&#13;
&#13;
    constructor() public{&#13;
        owner = msg.sender;&#13;
        manager = msg.sender;&#13;
    }&#13;
&#13;
    function getHashDigest(string _id) view public returns (string, string, bytes32){&#13;
        return (student[_id].fCode, student[_id].session, student[_id].hash);&#13;
    }&#13;
&#13;
    function addStudent(string _id, string _fCode, string _session, bytes32 _hash) restricted public {&#13;
        require(student[_id].hash == 0x0);&#13;
        student[_id].hash = _hash;&#13;
        student[_id].fCode = _fCode;&#13;
        student[_id].session = _session;&#13;
    }&#13;
&#13;
    function addStudents(string _ids, string _fCodes, string _sessions, bytes32 [] _hashes, uint _len) restricted public {&#13;
        string  memory id;&#13;
        string  memory fCode;&#13;
        string  memory session;&#13;
        for (uint i = 0; i &lt; _len; i++) {&#13;
            id = sub_id(_ids, i);&#13;
            fCode = sub_fCode(_fCodes, i);&#13;
            session = sub_session(_sessions, i);&#13;
            addStudent(id, fCode, session, _hashes[i]);&#13;
        }&#13;
    }&#13;
&#13;
    function subset(string _source, uint _pos, uint _LENGTH) pure private returns (string) {&#13;
        bytes memory strBytes = bytes(_source);&#13;
        bytes memory result = new bytes(_LENGTH);&#13;
        for (uint i = (_pos * _LENGTH); i &lt; (_pos * _LENGTH + _LENGTH); i++) {&#13;
            result[i - (_pos * _LENGTH)] = strBytes[i];&#13;
        }&#13;
        return string(result);&#13;
    }&#13;
&#13;
    function sub_id(string str, uint pos) pure private returns (string) {&#13;
        return subset(str, pos, ID_LENGTH);&#13;
    }&#13;
&#13;
    function sub_fCode(string str, uint pos) pure private returns (string) {&#13;
        return subset(str, pos, FCODE_LENGTH);&#13;
    }&#13;
&#13;
    function sub_session(string str, uint pos) pure private returns (string) {&#13;
        return subset(str, pos, SESSION_LENGTH);&#13;
    }&#13;
&#13;
    function removeStudent(string _id) restricted public {&#13;
        require(student[_id].hash != 0x00);&#13;
        student[_id].hash = 0x00;&#13;
        student[_id].fCode = '';&#13;
        student[_id].session = '';&#13;
    }&#13;
&#13;
    function changeOwner(address _new_owner) restricted public{&#13;
        owner = _new_owner;&#13;
    }&#13;
&#13;
    function restoreOwner() restrictedToManager public {&#13;
        owner = manager;&#13;
    }&#13;
&#13;
}