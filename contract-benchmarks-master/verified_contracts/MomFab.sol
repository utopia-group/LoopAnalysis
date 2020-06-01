// hevm: flattened sources of src/fab.sol
pragma solidity ^0.4.18;

////// lib/ds-guard/lib/ds-auth/src/auth.sol
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

/* pragma solidity ^0.4.13; */

contract DSAuthority {
    function canCall(
        address src, address dst, bytes4 sig
    ) public view returns (bool);
}

contract DSAuthEvents {
    event LogSetAuthority (address indexed authority);
    event LogSetOwner     (address indexed owner);
}

contract DSAuth is DSAuthEvents {
    DSAuthority  public  authority;
    address      public  owner;

    function DSAuth() public {
        owner = msg.sender;
        LogSetOwner(msg.sender);
    }

    function setOwner(address owner_)
        public
        auth
    {
        owner = owner_;
        LogSetOwner(owner);
    }

    function setAuthority(DSAuthority authority_)
        public
        auth
    {
        authority = authority_;
        LogSetAuthority(authority);
    }

    modifier auth {
        require(isAuthorized(msg.sender, msg.sig));
        _;
    }

    function isAuthorized(address src, bytes4 sig) internal view returns (bool) {
        if (src == address(this)) {
            return true;
        } else if (src == owner) {
            return true;
        } else if (authority == DSAuthority(0)) {
            return false;
        } else {
            return authority.canCall(src, this, sig);
        }
    }
}

////// lib/ds-guard/src/guard.sol
// guard.sol -- simple whitelist implementation of DSAuthority

// Copyright (C) 2017  DappHub, LLC

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

/* pragma solidity ^0.4.13; */

/* import "ds-auth/auth.sol"; */

contract DSGuardEvents {
    event LogPermit(
        bytes32 indexed src,
        bytes32 indexed dst,
        bytes32 indexed sig
    );

    event LogForbid(
        bytes32 indexed src,
        bytes32 indexed dst,
        bytes32 indexed sig
    );
}

contract DSGuard is DSAuth, DSAuthority, DSGuardEvents {
    bytes32 constant public ANY = bytes32(uint(-1));

    mapping (bytes32 => mapping (bytes32 => mapping (bytes32 => bool))) acl;

    function canCall(
        address src_, address dst_, bytes4 sig
    ) public view returns (bool) {
        var src = bytes32(src_);
        var dst = bytes32(dst_);

        return acl[src][dst][sig]
            || acl[src][dst][ANY]
            || acl[src][ANY][sig]
            || acl[src][ANY][ANY]
            || acl[ANY][dst][sig]
            || acl[ANY][dst][ANY]
            || acl[ANY][ANY][sig]
            || acl[ANY][ANY][ANY];
    }

    function permit(bytes32 src, bytes32 dst, bytes32 sig) public auth {
        acl[src][dst][sig] = true;
        LogPermit(src, dst, sig);
    }

    function forbid(bytes32 src, bytes32 dst, bytes32 sig) public auth {
        acl[src][dst][sig] = false;
        LogForbid(src, dst, sig);
    }

    function permit(address src, address dst, bytes32 sig) public {
        permit(bytes32(src), bytes32(dst), sig);
    }
    function forbid(address src, address dst, bytes32 sig) public {
        forbid(bytes32(src), bytes32(dst), sig);
    }

}

contract DSGuardFactory {
    mapping (address => bool)  public  isGuard;

    function newGuard() public returns (DSGuard guard) {
        guard = new DSGuard();
        guard.setOwner(msg.sender);
        isGuard[guard] = true;
    }
}

////// lib/ds-roles/src/roles.sol
// roles.sol - roled based authentication

// Copyright (C) 2017  DappHub, LLC

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

/* pragma solidity ^0.4.13; */

/* import 'ds-auth/auth.sol'; */

contract DSRoles is DSAuth, DSAuthority
{
    mapping(address=>bool) _root_users;
    mapping(address=>bytes32) _user_roles;
    mapping(address=>mapping(bytes4=>bytes32)) _capability_roles;
    mapping(address=>mapping(bytes4=>bool)) _public_capabilities;

    function getUserRoles(address who)
        public
        view
        returns (bytes32)
    {
        return _user_roles[who];
    }

    function getCapabilityRoles(address code, bytes4 sig)
        public
        view
        returns (bytes32)
    {
        return _capability_roles[code][sig];
    }

    function isUserRoot(address who)
        public
        view
        returns (bool)
    {
        return _root_users[who];
    }

    function isCapabilityPublic(address code, bytes4 sig)
        public
        view
        returns (bool)
    {
        return _public_capabilities[code][sig];
    }

    function hasUserRole(address who, uint8 role)
        public
        view
        returns (bool)
    {
        bytes32 roles = getUserRoles(who);
        bytes32 shifted = bytes32(uint256(uint256(2) ** uint256(role)));
        return bytes32(0) != roles & shifted;
    }

    function canCall(address caller, address code, bytes4 sig)
        public
        view
        returns (bool)
    {
        if( isUserRoot(caller) || isCapabilityPublic(code, sig) ) {
            return true;
        } else {
            var has_roles = getUserRoles(caller);
            var needs_one_of = getCapabilityRoles(code, sig);
            return bytes32(0) != has_roles & needs_one_of;
        }
    }

    function BITNOT(bytes32 input) internal pure returns (bytes32 output) {
        return (input ^ bytes32(uint(-1)));
    }

    function setRootUser(address who, bool enabled)
        public
        auth
    {
        _root_users[who] = enabled;
    }

    function setUserRole(address who, uint8 role, bool enabled)
        public
        auth
    {
        var last_roles = _user_roles[who];
        bytes32 shifted = bytes32(uint256(uint256(2) ** uint256(role)));
        if( enabled ) {
            _user_roles[who] = last_roles | shifted;
        } else {
            _user_roles[who] = last_roles & BITNOT(shifted);
        }
    }

    function setPublicCapability(address code, bytes4 sig, bool enabled)
        public
        auth
    {
        _public_capabilities[code][sig] = enabled;
    }

    function setRoleCapability(uint8 role, address code, bytes4 sig, bool enabled)
        public
        auth
    {
        var last_roles = _capability_roles[code][sig];
        bytes32 shifted = bytes32(uint256(uint256(2) ** uint256(role)));
        if( enabled ) {
            _capability_roles[code][sig] = last_roles | shifted;
        } else {
            _capability_roles[code][sig] = last_roles & BITNOT(shifted);
        }

    }

}

////// lib/ds-spell/lib/ds-note/src/note.sol
/// note.sol -- the `note' modifier, for logging calls as events

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

/* pragma solidity ^0.4.13; */

contract DSNote {
    event LogNote(
        bytes4   indexed  sig,
        address  indexed  guy,
        bytes32  indexed  foo,
        bytes32  indexed  bar,
        uint              wad,
        bytes             fax
    ) anonymous;

    modifier note {
        bytes32 foo;
        bytes32 bar;

        assembly {
            foo := calldataload(4)
            bar := calldataload(36)
        }

        LogNote(msg.sig, msg.sender, foo, bar, msg.value, msg.data);

        _;
    }
}

////// lib/ds-thing/lib/ds-math/src/math.sol
/// math.sol -- mixin for inline numerical wizardry

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

/* pragma solidity ^0.4.13; */

contract DSMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x);
    }
    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x);
    }
    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x);
    }

    function min(uint x, uint y) internal pure returns (uint z) {
        return x <= y ? x : y;
    }
    function max(uint x, uint y) internal pure returns (uint z) {
        return x >= y ? x : y;
    }
    function imin(int x, int y) internal pure returns (int z) {
        return x <= y ? x : y;
    }
    function imax(int x, int y) internal pure returns (int z) {
        return x >= y ? x : y;
    }

    uint constant WAD = 10 ** 18;
    uint constant RAY = 10 ** 27;

    function wmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), WAD / 2) / WAD;
    }
    function rmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), RAY / 2) / RAY;
    }
    function wdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, WAD), y / 2) / y;
    }
    function rdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, RAY), y / 2) / y;
    }

    // This famous algorithm is called "exponentiation by squaring"
    // and calculates x^n with x as fixed-point and n as regular unsigned.
    //
    // It's O(log n), instead of O(n) for naive repeated multiplication.
    //
    // These facts are why it works:
    //
    //  If n is even, then x^n = (x^2)^(n/2).
    //  If n is odd,  then x^n = x * x^(n-1),
    //   and applying the equation for even x gives
    //    x^n = x * (x^2)^((n-1) / 2).
    //
    //  Also, EVM division is flooring and
    //    floor[(n-1) / 2] = floor[n / 2].
    //
    function rpow(uint x, uint n) internal pure returns (uint z) {
        z = n % 2 != 0 ? x : RAY;

        for (n /= 2; n != 0; n /= 2) {
            x = rmul(x, x);

            if (n % 2 != 0) {
                z = rmul(z, x);
            }
        }
    }
}

////// lib/ds-thing/src/thing.sol
// thing.sol - `auth` with handy mixins. your things should be DSThings

// Copyright (C) 2017  DappHub, LLC

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

/* pragma solidity ^0.4.13; */

/* import 'ds-auth/auth.sol'; */
/* import 'ds-note/note.sol'; */
/* import 'ds-math/math.sol'; */

contract DSThing is DSAuth, DSNote, DSMath {

    function S(string s) internal pure returns (bytes4) {
        return bytes4(keccak256(s));
    }

}

////// lib/ds-token/lib/ds-stop/src/stop.sol
/// stop.sol -- mixin for enable/disable functionality

// Copyright (C) 2017  DappHub, LLC

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

/* pragma solidity ^0.4.13; */

/* import "ds-auth/auth.sol"; */
/* import "ds-note/note.sol"; */

contract DSStop is DSNote, DSAuth {

    bool public stopped;

    modifier stoppable {
        require(!stopped);
        _;
    }
    function stop() public auth note {
        stopped = true;
    }
    function start() public auth note {
        stopped = false;
    }

}

////// lib/ds-token/lib/erc20/src/erc20.sol
/// erc20.sol -- API for the ERC20 token standard

// See <https://github.com/ethereum/EIPs/issues/20>.

// This file likely does not meet the threshold of originality
// required for copyright to apply.  As a result, this is free and
// unencumbered software belonging to the public domain.

/* pragma solidity ^0.4.8; */

contract ERC20Events {
    event Approval(address indexed src, address indexed guy, uint wad);
    event Transfer(address indexed src, address indexed dst, uint wad);
}

contract ERC20 is ERC20Events {
    function totalSupply() public view returns (uint);
    function balanceOf(address guy) public view returns (uint);
    function allowance(address src, address guy) public view returns (uint);

    function approve(address guy, uint wad) public returns (bool);
    function transfer(address dst, uint wad) public returns (bool);
    function transferFrom(
        address src, address dst, uint wad
    ) public returns (bool);
}

////// lib/ds-token/src/base.sol
/// base.sol -- basic ERC20 implementation

// Copyright (C) 2015, 2016, 2017  DappHub, LLC

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

/* pragma solidity ^0.4.13; */

/* import "erc20/erc20.sol"; */
/* import "ds-math/math.sol"; */

contract DSTokenBase is ERC20, DSMath {
    uint256                                            _supply;
    mapping (address => uint256)                       _balances;
    mapping (address => mapping (address => uint256))  _approvals;

    function DSTokenBase(uint supply) public {
        _balances[msg.sender] = supply;
        _supply = supply;
    }

    function totalSupply() public view returns (uint) {
        return _supply;
    }
    function balanceOf(address src) public view returns (uint) {
        return _balances[src];
    }
    function allowance(address src, address guy) public view returns (uint) {
        return _approvals[src][guy];
    }

    function transfer(address dst, uint wad) public returns (bool) {
        return transferFrom(msg.sender, dst, wad);
    }

    function transferFrom(address src, address dst, uint wad)
        public
        returns (bool)
    {
        if (src != msg.sender) {
            _approvals[src][msg.sender] = sub(_approvals[src][msg.sender], wad);
        }

        _balances[src] = sub(_balances[src], wad);
        _balances[dst] = add(_balances[dst], wad);

        Transfer(src, dst, wad);

        return true;
    }

    function approve(address guy, uint wad) public returns (bool) {
        _approvals[msg.sender][guy] = wad;

        Approval(msg.sender, guy, wad);

        return true;
    }
}

////// lib/ds-token/src/token.sol
/// token.sol -- ERC20 implementation with minting and burning

// Copyright (C) 2015, 2016, 2017  DappHub, LLC

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

/* pragma solidity ^0.4.13; */

/* import "ds-stop/stop.sol"; */

/* import "./base.sol"; */

contract DSToken is DSTokenBase(0), DSStop {

    bytes32  public  symbol;
    uint256  public  decimals = 18; // standard token precision. override to customize

    function DSToken(bytes32 symbol_) public {
        symbol = symbol_;
    }

    event Mint(address indexed guy, uint wad);
    event Burn(address indexed guy, uint wad);

    function approve(address guy) public stoppable returns (bool) {
        return super.approve(guy, uint(-1));
    }

    function approve(address guy, uint wad) public stoppable returns (bool) {
        return super.approve(guy, wad);
    }

    function transferFrom(address src, address dst, uint wad)
        public
        stoppable
        returns (bool)
    {
        if (src != msg.sender && _approvals[src][msg.sender] != uint(-1)) {
            _approvals[src][msg.sender] = sub(_approvals[src][msg.sender], wad);
        }

        _balances[src] = sub(_balances[src], wad);
        _balances[dst] = add(_balances[dst], wad);

        Transfer(src, dst, wad);

        return true;
    }

    function push(address dst, uint wad) public {
        transferFrom(msg.sender, dst, wad);
    }
    function pull(address src, uint wad) public {
        transferFrom(src, msg.sender, wad);
    }
    function move(address src, address dst, uint wad) public {
        transferFrom(src, dst, wad);
    }

    function mint(uint wad) public {
        mint(msg.sender, wad);
    }
    function burn(uint wad) public {
        burn(msg.sender, wad);
    }
    function mint(address guy, uint wad) public auth stoppable {
        _balances[guy] = add(_balances[guy], wad);
        _supply = add(_supply, wad);
        Mint(guy, wad);
    }
    function burn(address guy, uint wad) public auth stoppable {
        if (guy != msg.sender && _approvals[guy][msg.sender] != uint(-1)) {
            _approvals[guy][msg.sender] = sub(_approvals[guy][msg.sender], wad);
        }

        _balances[guy] = sub(_balances[guy], wad);
        _supply = sub(_supply, wad);
        Burn(guy, wad);
    }

    // Optional token name
    bytes32   public  name = "";

    function setName(bytes32 name_) public auth {
        name = name_;
    }
}

////// lib/ds-value/src/value.sol
/// value.sol - a value is a simple thing, it can be get and set

// Copyright (C) 2017  DappHub, LLC

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

/* pragma solidity ^0.4.13; */

/* import 'ds-thing/thing.sol'; */

contract DSValue is DSThing {
    bool    has;
    bytes32 val;
    function peek() public view returns (bytes32, bool) {
        return (val,has);
    }
    function read() public view returns (bytes32) {
        var (wut, haz) = peek();
        assert(haz);
        return wut;
    }
    function poke(bytes32 wut) public note auth {
        val = wut;
        has = true;
    }
    function void() public note auth {  // unset the value
        has = false;
    }
}

////// src/vox.sol
/// vox.sol -- target price feed

// Copyright (C) 2016, 2017  Nikolai Mushegian <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="87e9eeece8ebe6eec7e3e6f7f7eff2e5a9e4e8ea">[email protected]</a>&gt;&#13;
// Copyright (C) 2016, 2017  Daniel Brockman &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="1b7f7a75727e775b7f7a6b6b736e7935787476">[email protected]</a>&gt;&#13;
// Copyright (C) 2017        Rain Break &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="6c1e0d05020e1e090d072c1e051f09191c42020918">[email protected]</a>&gt;&#13;
&#13;
// This program is free software: you can redistribute it and/or modify&#13;
// it under the terms of the GNU General Public License as published by&#13;
// the Free Software Foundation, either version 3 of the License, or&#13;
// (at your option) any later version.&#13;
&#13;
// This program is distributed in the hope that it will be useful,&#13;
// but WITHOUT ANY WARRANTY; without even the implied warranty of&#13;
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the&#13;
// GNU General Public License for more details.&#13;
&#13;
// You should have received a copy of the GNU General Public License&#13;
// along with this program.  If not, see &lt;http://www.gnu.org/licenses/&gt;.&#13;
&#13;
/* pragma solidity ^0.4.18; */&#13;
&#13;
/* import "ds-thing/thing.sol"; */&#13;
&#13;
contract SaiVox is DSThing {&#13;
    uint256  _par;&#13;
    uint256  _way;&#13;
&#13;
    uint256  public  fix;&#13;
    uint256  public  how;&#13;
    uint256  public  tau;&#13;
&#13;
    function SaiVox(uint par_) public {&#13;
        _par = fix = par_;&#13;
        _way = RAY;&#13;
        tau  = era();&#13;
    }&#13;
&#13;
    function era() public view returns (uint) {&#13;
        return block.timestamp;&#13;
    }&#13;
&#13;
    function mold(bytes32 param, uint val) public note auth {&#13;
        if (param == 'way') _way = val;&#13;
    }&#13;
&#13;
    // Dai Target Price (ref per dai)&#13;
    function par() public returns (uint) {&#13;
        prod();&#13;
        return _par;&#13;
    }&#13;
    function way() public returns (uint) {&#13;
        prod();&#13;
        return _way;&#13;
    }&#13;
&#13;
    function tell(uint256 ray) public note auth {&#13;
        fix = ray;&#13;
    }&#13;
    function tune(uint256 ray) public note auth {&#13;
        how = ray;&#13;
    }&#13;
&#13;
    function prod() public note {&#13;
        var age = era() - tau;&#13;
        if (age == 0) return;  // optimised&#13;
        tau = era();&#13;
&#13;
        if (_way != RAY) _par = rmul(_par, rpow(_way, age));  // optimised&#13;
&#13;
        if (how == 0) return;  // optimised&#13;
        var wag = int128(how * age);&#13;
        _way = inj(prj(_way) + (fix &lt; _par ? wag : -wag));&#13;
    }&#13;
&#13;
    function inj(int128 x) internal pure returns (uint256) {&#13;
        return x &gt;= 0 ? uint256(x) + RAY&#13;
            : rdiv(RAY, RAY + uint256(-x));&#13;
    }&#13;
    function prj(uint256 x) internal pure returns (int128) {&#13;
        return x &gt;= RAY ? int128(x - RAY)&#13;
            : int128(RAY) - int128(rdiv(RAY, x));&#13;
    }&#13;
}&#13;
&#13;
////// src/tub.sol&#13;
/// tub.sol -- simplified CDP engine (baby brother of `vat')&#13;
&#13;
// Copyright (C) 2017  Nikolai Mushegian &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="e6888f8d898a878fa6828796968e9384c885898b">[email protected]</a>&gt;&#13;
// Copyright (C) 2017  Daniel Brockman &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="7014111e19151c30141100001805125e131f1d">[email protected]</a>&gt;&#13;
// Copyright (C) 2017  Rain Break &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="dcaebdb5b2beaeb9bdb79caeb5afb9a9acf2b2b9a8">[email protected]</a>&gt;&#13;
&#13;
// This program is free software: you can redistribute it and/or modify&#13;
// it under the terms of the GNU General Public License as published by&#13;
// the Free Software Foundation, either version 3 of the License, or&#13;
// (at your option) any later version.&#13;
&#13;
// This program is distributed in the hope that it will be useful,&#13;
// but WITHOUT ANY WARRANTY; without even the implied warranty of&#13;
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the&#13;
// GNU General Public License for more details.&#13;
&#13;
// You should have received a copy of the GNU General Public License&#13;
// along with this program.  If not, see &lt;http://www.gnu.org/licenses/&gt;.&#13;
&#13;
/* pragma solidity ^0.4.18; */&#13;
&#13;
/* import "ds-thing/thing.sol"; */&#13;
/* import "ds-token/token.sol"; */&#13;
/* import "ds-value/value.sol"; */&#13;
&#13;
/* import "./vox.sol"; */&#13;
&#13;
contract SaiTubEvents {&#13;
    event LogNewCup(address indexed lad, bytes32 cup);&#13;
}&#13;
&#13;
contract SaiTub is DSThing, SaiTubEvents {&#13;
    DSToken  public  sai;  // Stablecoin&#13;
    DSToken  public  sin;  // Debt (negative sai)&#13;
&#13;
    DSToken  public  skr;  // Abstracted collateral&#13;
    ERC20    public  gem;  // Underlying collateral&#13;
&#13;
    DSToken  public  gov;  // Governance token&#13;
&#13;
    SaiVox   public  vox;  // Target price feed&#13;
    DSValue  public  pip;  // Reference price feed&#13;
    DSValue  public  pep;  // Governance price feed&#13;
&#13;
    address  public  tap;  // Liquidator&#13;
    address  public  pit;  // Governance Vault&#13;
&#13;
    uint256  public  axe;  // Liquidation penalty&#13;
    uint256  public  cap;  // Debt ceiling&#13;
    uint256  public  mat;  // Liquidation ratio&#13;
    uint256  public  tax;  // Stability fee&#13;
    uint256  public  fee;  // Governance fee&#13;
    uint256  public  gap;  // Join-Exit Spread&#13;
&#13;
    bool     public  off;  // Cage flag&#13;
    bool     public  out;  // Post cage exit&#13;
&#13;
    uint256  public  fit;  // REF per SKR (just before settlement)&#13;
&#13;
    uint256  public  rho;  // Time of last drip&#13;
    uint256         _chi;  // Accumulated Tax Rates&#13;
    uint256         _rhi;  // Accumulated Tax + Fee Rates&#13;
    uint256  public  rum;  // Total normalised debt&#13;
&#13;
    uint256                   public  cupi;&#13;
    mapping (bytes32 =&gt; Cup)  public  cups;&#13;
&#13;
    struct Cup {&#13;
        address  lad;      // CDP owner&#13;
        uint256  ink;      // Locked collateral (in SKR)&#13;
        uint256  art;      // Outstanding normalised debt (tax only)&#13;
        uint256  ire;      // Outstanding normalised debt&#13;
    }&#13;
&#13;
    function lad(bytes32 cup) public view returns (address) {&#13;
        return cups[cup].lad;&#13;
    }&#13;
    function ink(bytes32 cup) public view returns (uint) {&#13;
        return cups[cup].ink;&#13;
    }&#13;
    function tab(bytes32 cup) public returns (uint) {&#13;
        return rmul(cups[cup].art, chi());&#13;
    }&#13;
    function rap(bytes32 cup) public returns (uint) {&#13;
        return sub(rmul(cups[cup].ire, rhi()), tab(cup));&#13;
    }&#13;
&#13;
    // Total CDP Debt&#13;
    function din() public returns (uint) {&#13;
        return rmul(rum, chi());&#13;
    }&#13;
    // Backing collateral&#13;
    function air() public view returns (uint) {&#13;
        return skr.balanceOf(this);&#13;
    }&#13;
    // Raw collateral&#13;
    function pie() public view returns (uint) {&#13;
        return gem.balanceOf(this);&#13;
    }&#13;
&#13;
    //------------------------------------------------------------------&#13;
&#13;
    function SaiTub(&#13;
        DSToken  sai_,&#13;
        DSToken  sin_,&#13;
        DSToken  skr_,&#13;
        ERC20    gem_,&#13;
        DSToken  gov_,&#13;
        DSValue  pip_,&#13;
        DSValue  pep_,&#13;
        SaiVox   vox_,&#13;
        address  pit_&#13;
    ) public {&#13;
        gem = gem_;&#13;
        skr = skr_;&#13;
&#13;
        sai = sai_;&#13;
        sin = sin_;&#13;
&#13;
        gov = gov_;&#13;
        pit = pit_;&#13;
&#13;
        pip = pip_;&#13;
        pep = pep_;&#13;
        vox = vox_;&#13;
&#13;
        axe = RAY;&#13;
        mat = RAY;&#13;
        tax = RAY;&#13;
        fee = RAY;&#13;
        gap = WAD;&#13;
&#13;
        _chi = RAY;&#13;
        _rhi = RAY;&#13;
&#13;
        rho = era();&#13;
    }&#13;
&#13;
    function era() public constant returns (uint) {&#13;
        return block.timestamp;&#13;
    }&#13;
&#13;
    //--Risk-parameter-config-------------------------------------------&#13;
&#13;
    function mold(bytes32 param, uint val) public note auth {&#13;
        if      (param == 'cap') cap = val;&#13;
        else if (param == 'mat') { require(val &gt;= RAY); mat = val; }&#13;
        else if (param == 'tax') { require(val &gt;= RAY); drip(); tax = val; }&#13;
        else if (param == 'fee') { require(val &gt;= RAY); drip(); fee = val; }&#13;
        else if (param == 'axe') { require(val &gt;= RAY); axe = val; }&#13;
        else if (param == 'gap') { require(val &gt;= WAD); gap = val; }&#13;
        else return;&#13;
    }&#13;
&#13;
    //--Price-feed-setters----------------------------------------------&#13;
&#13;
    function setPip(DSValue pip_) public note auth {&#13;
        pip = pip_;&#13;
    }&#13;
    function setPep(DSValue pep_) public note auth {&#13;
        pep = pep_;&#13;
    }&#13;
    function setVox(SaiVox vox_) public note auth {&#13;
        vox = vox_;&#13;
    }&#13;
&#13;
    //--Tap-setter------------------------------------------------------&#13;
    function turn(address tap_) public note {&#13;
        require(tap  == 0);&#13;
        require(tap_ != 0);&#13;
        tap = tap_;&#13;
    }&#13;
&#13;
    //--Collateral-wrapper----------------------------------------------&#13;
&#13;
    // Wrapper ratio (gem per skr)&#13;
    function per() public view returns (uint ray) {&#13;
        return skr.totalSupply() == 0 ? RAY : rdiv(pie(), skr.totalSupply());&#13;
    }&#13;
    // Join price (gem per skr)&#13;
    function ask(uint wad) public view returns (uint) {&#13;
        return rmul(wad, wmul(per(), gap));&#13;
    }&#13;
    // Exit price (gem per skr)&#13;
    function bid(uint wad) public view returns (uint) {&#13;
        return rmul(wad, wmul(per(), sub(2 * WAD, gap)));&#13;
    }&#13;
    function join(uint wad) public note {&#13;
        require(!off);&#13;
        require(ask(wad) &gt; 0);&#13;
        require(gem.transferFrom(msg.sender, this, ask(wad)));&#13;
        skr.mint(msg.sender, wad);&#13;
    }&#13;
    function exit(uint wad) public note {&#13;
        require(!off || out);&#13;
        require(gem.transfer(msg.sender, bid(wad)));&#13;
        skr.burn(msg.sender, wad);&#13;
    }&#13;
&#13;
    //--Stability-fee-accumulation--------------------------------------&#13;
&#13;
    // Accumulated Rates&#13;
    function chi() public returns (uint) {&#13;
        drip();&#13;
        return _chi;&#13;
    }&#13;
    function rhi() public returns (uint) {&#13;
        drip();&#13;
        return _rhi;&#13;
    }&#13;
    function drip() public note {&#13;
        if (off) return;&#13;
&#13;
        var rho_ = era();&#13;
        var age = rho_ - rho;&#13;
        if (age == 0) return;    // optimised&#13;
        rho = rho_;&#13;
&#13;
        var inc = RAY;&#13;
&#13;
        if (tax != RAY) {  // optimised&#13;
            var _chi_ = _chi;&#13;
            inc = rpow(tax, age);&#13;
            _chi = rmul(_chi, inc);&#13;
            sai.mint(tap, rmul(sub(_chi, _chi_), rum));&#13;
        }&#13;
&#13;
        // optimised&#13;
        if (fee != RAY) inc = rmul(inc, rpow(fee, age));&#13;
        if (inc != RAY) _rhi = rmul(_rhi, inc);&#13;
    }&#13;
&#13;
&#13;
    //--CDP-risk-indicator----------------------------------------------&#13;
&#13;
    // Abstracted collateral price (ref per skr)&#13;
    function tag() public view returns (uint wad) {&#13;
        return off ? fit : wmul(per(), uint(pip.read()));&#13;
    }&#13;
    // Returns true if cup is well-collateralized&#13;
    function safe(bytes32 cup) public returns (bool) {&#13;
        var pro = rmul(tag(), ink(cup));&#13;
        var con = rmul(vox.par(), tab(cup));&#13;
        var min = rmul(con, mat);&#13;
        return pro &gt;= min;&#13;
    }&#13;
&#13;
&#13;
    //--CDP-operations--------------------------------------------------&#13;
&#13;
    function open() public note returns (bytes32 cup) {&#13;
        require(!off);&#13;
        cupi = add(cupi, 1);&#13;
        cup = bytes32(cupi);&#13;
        cups[cup].lad = msg.sender;&#13;
        LogNewCup(msg.sender, cup);&#13;
    }&#13;
    function give(bytes32 cup, address guy) public note {&#13;
        require(msg.sender == cups[cup].lad);&#13;
        require(guy != 0);&#13;
        cups[cup].lad = guy;&#13;
    }&#13;
&#13;
    function lock(bytes32 cup, uint wad) public note {&#13;
        require(!off);&#13;
        cups[cup].ink = add(cups[cup].ink, wad);&#13;
        skr.pull(msg.sender, wad);&#13;
        require(cups[cup].ink == 0 || cups[cup].ink &gt; 0.005 ether);&#13;
    }&#13;
    function free(bytes32 cup, uint wad) public note {&#13;
        require(msg.sender == cups[cup].lad);&#13;
        cups[cup].ink = sub(cups[cup].ink, wad);&#13;
        skr.push(msg.sender, wad);&#13;
        require(safe(cup));&#13;
        require(cups[cup].ink == 0 || cups[cup].ink &gt; 0.005 ether);&#13;
    }&#13;
&#13;
    function draw(bytes32 cup, uint wad) public note {&#13;
        require(!off);&#13;
        require(msg.sender == cups[cup].lad);&#13;
        require(rdiv(wad, chi()) &gt; 0);&#13;
&#13;
        cups[cup].art = add(cups[cup].art, rdiv(wad, chi()));&#13;
        rum = add(rum, rdiv(wad, chi()));&#13;
&#13;
        cups[cup].ire = add(cups[cup].ire, rdiv(wad, rhi()));&#13;
        sai.mint(cups[cup].lad, wad);&#13;
&#13;
        require(safe(cup));&#13;
        require(sai.totalSupply() &lt;= cap);&#13;
    }&#13;
    function wipe(bytes32 cup, uint wad) public note {&#13;
        require(!off);&#13;
&#13;
        var owe = rmul(wad, rdiv(rap(cup), tab(cup)));&#13;
&#13;
        cups[cup].art = sub(cups[cup].art, rdiv(wad, chi()));&#13;
        rum = sub(rum, rdiv(wad, chi()));&#13;
&#13;
        cups[cup].ire = sub(cups[cup].ire, rdiv(add(wad, owe), rhi()));&#13;
        sai.burn(msg.sender, wad);&#13;
&#13;
        var (val, ok) = pep.peek();&#13;
        if (ok &amp;&amp; val != 0) gov.move(msg.sender, pit, wdiv(owe, uint(val)));&#13;
    }&#13;
&#13;
    function shut(bytes32 cup) public note {&#13;
        require(!off);&#13;
        require(msg.sender == cups[cup].lad);&#13;
        if (tab(cup) != 0) wipe(cup, tab(cup));&#13;
        if (ink(cup) != 0) free(cup, ink(cup));&#13;
        delete cups[cup];&#13;
    }&#13;
&#13;
    function bite(bytes32 cup) public note {&#13;
        require(!safe(cup) || off);&#13;
&#13;
        // Take on all of the debt, except unpaid fees&#13;
        var rue = tab(cup);&#13;
        sin.mint(tap, rue);&#13;
        rum = sub(rum, cups[cup].art);&#13;
        cups[cup].art = 0;&#13;
        cups[cup].ire = 0;&#13;
&#13;
        // Amount owed in SKR, including liquidation penalty&#13;
        var owe = rdiv(rmul(rmul(rue, axe), vox.par()), tag());&#13;
&#13;
        if (owe &gt; cups[cup].ink) {&#13;
            owe = cups[cup].ink;&#13;
        }&#13;
&#13;
        skr.push(tap, owe);&#13;
        cups[cup].ink = sub(cups[cup].ink, owe);&#13;
    }&#13;
&#13;
    //------------------------------------------------------------------&#13;
&#13;
    function cage(uint fit_, uint jam) public note auth {&#13;
        require(!off &amp;&amp; fit_ != 0);&#13;
        off = true;&#13;
        axe = RAY;&#13;
        gap = WAD;&#13;
        fit = fit_;         // ref per skr&#13;
        require(gem.transfer(tap, jam));&#13;
    }&#13;
    function flow() public note auth {&#13;
        require(off);&#13;
        out = true;&#13;
    }&#13;
}&#13;
&#13;
////// src/tap.sol&#13;
/// tap.sol -- liquidation engine (see also `vow`)&#13;
&#13;
// Copyright (C) 2017  Nikolai Mushegian &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="89e7e0e2e6e5e8e0c9ede8f9f9e1fceba7eae6e4">[email protected]</a>&gt;&#13;
// Copyright (C) 2017  Daniel Brockman &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="f69297989f939ab6929786869e8394d895999b">[email protected]</a>&gt;&#13;
// Copyright (C) 2017  Rain Break &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="a1d3c0c8cfc3d3c4c0cae1d3c8d2c4d4d18fcfc4d5">[email protected]</a>&gt;&#13;
&#13;
// This program is free software: you can redistribute it and/or modify&#13;
// it under the terms of the GNU General Public License as published by&#13;
// the Free Software Foundation, either version 3 of the License, or&#13;
// (at your option) any later version.&#13;
&#13;
// This program is distributed in the hope that it will be useful,&#13;
// but WITHOUT ANY WARRANTY; without even the implied warranty of&#13;
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the&#13;
// GNU General Public License for more details.&#13;
&#13;
// You should have received a copy of the GNU General Public License&#13;
// along with this program.  If not, see &lt;http://www.gnu.org/licenses/&gt;.&#13;
&#13;
/* pragma solidity ^0.4.18; */&#13;
&#13;
/* import "./tub.sol"; */&#13;
&#13;
contract SaiTap is DSThing {&#13;
    DSToken  public  sai;&#13;
    DSToken  public  sin;&#13;
    DSToken  public  skr;&#13;
&#13;
    SaiVox   public  vox;&#13;
    SaiTub   public  tub;&#13;
&#13;
    uint256  public  gap;  // Boom-Bust Spread&#13;
    bool     public  off;  // Cage flag&#13;
    uint256  public  fix;  // Cage price&#13;
&#13;
    // Surplus&#13;
    function joy() public view returns (uint) {&#13;
        return sai.balanceOf(this);&#13;
    }&#13;
    // Bad debt&#13;
    function woe() public view returns (uint) {&#13;
        return sin.balanceOf(this);&#13;
    }&#13;
    // Collateral pending liquidation&#13;
    function fog() public view returns (uint) {&#13;
        return skr.balanceOf(this);&#13;
    }&#13;
&#13;
&#13;
    function SaiTap(SaiTub tub_) public {&#13;
        tub = tub_;&#13;
&#13;
        sai = tub.sai();&#13;
        sin = tub.sin();&#13;
        skr = tub.skr();&#13;
&#13;
        vox = tub.vox();&#13;
&#13;
        gap = WAD;&#13;
    }&#13;
&#13;
    function mold(bytes32 param, uint val) public note auth {&#13;
        if (param == 'gap') gap = val;&#13;
    }&#13;
&#13;
    // Cancel debt&#13;
    function heal() public note {&#13;
        if (joy() == 0 || woe() == 0) return;  // optimised&#13;
        var wad = min(joy(), woe());&#13;
        sai.burn(wad);&#13;
        sin.burn(wad);&#13;
    }&#13;
&#13;
    // Feed price (sai per skr)&#13;
    function s2s() public returns (uint) {&#13;
        var tag = tub.tag();    // ref per skr&#13;
        var par = vox.par();    // ref per sai&#13;
        return rdiv(tag, par);  // sai per skr&#13;
    }&#13;
    // Boom price (sai per skr)&#13;
    function bid(uint wad) public returns (uint) {&#13;
        return rmul(wad, wmul(s2s(), sub(2 * WAD, gap)));&#13;
    }&#13;
    // Bust price (sai per skr)&#13;
    function ask(uint wad) public returns (uint) {&#13;
        return rmul(wad, wmul(s2s(), gap));&#13;
    }&#13;
    function flip(uint wad) internal {&#13;
        require(ask(wad) &gt; 0);&#13;
        skr.push(msg.sender, wad);&#13;
        sai.pull(msg.sender, ask(wad));&#13;
        heal();&#13;
    }&#13;
    function flop(uint wad) internal {&#13;
        skr.mint(sub(wad, fog()));&#13;
        flip(wad);&#13;
        require(joy() == 0);  // can't flop into surplus&#13;
    }&#13;
    function flap(uint wad) internal {&#13;
        heal();&#13;
        sai.push(msg.sender, bid(wad));&#13;
        skr.burn(msg.sender, wad);&#13;
    }&#13;
    function bust(uint wad) public note {&#13;
        require(!off);&#13;
        if (wad &gt; fog()) flop(wad);&#13;
        else flip(wad);&#13;
    }&#13;
    function boom(uint wad) public note {&#13;
        require(!off);&#13;
        flap(wad);&#13;
    }&#13;
&#13;
    //------------------------------------------------------------------&#13;
&#13;
    function cage(uint fix_) public note auth {&#13;
        require(!off);&#13;
        off = true;&#13;
        fix = fix_;&#13;
    }&#13;
    function cash(uint wad) public note {&#13;
        require(off);&#13;
        sai.burn(msg.sender, wad);&#13;
        require(tub.gem().transfer(msg.sender, rmul(wad, fix)));&#13;
    }&#13;
    function mock(uint wad) public note {&#13;
        require(off);&#13;
        sai.mint(msg.sender, wad);&#13;
        require(tub.gem().transferFrom(msg.sender, this, rmul(wad, fix)));&#13;
    }&#13;
    function vent() public note {&#13;
        require(off);&#13;
        skr.burn(fog());&#13;
    }&#13;
}&#13;
&#13;
////// src/top.sol&#13;
/// top.sol -- global settlement manager&#13;
&#13;
// Copyright (C) 2017  Nikolai Mushegian &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="e58b8c8e8a89848ca5818495958d9087cb868a88">[email protected]</a>&gt;&#13;
// Copyright (C) 2017  Daniel Brockman &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="7b1f1a15121e173b1f1a0b0b130e1955181416">[email protected]</a>&gt;&#13;
// Copyright (C) 2017  Rain Break &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="6c1e0d05020e1e090d072c1e051f09191c42020918">[email protected]</a>&gt;&#13;
&#13;
// This program is free software: you can redistribute it and/or modify&#13;
// it under the terms of the GNU General Public License as published by&#13;
// the Free Software Foundation, either version 3 of the License, or&#13;
// (at your option) any later version.&#13;
&#13;
// This program is distributed in the hope that it will be useful,&#13;
// but WITHOUT ANY WARRANTY; without even the implied warranty of&#13;
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the&#13;
// GNU General Public License for more details.&#13;
&#13;
// You should have received a copy of the GNU General Public License&#13;
// along with this program.  If not, see &lt;http://www.gnu.org/licenses/&gt;.&#13;
&#13;
/* pragma solidity ^0.4.18; */&#13;
&#13;
/* import "./tub.sol"; */&#13;
/* import "./tap.sol"; */&#13;
&#13;
contract SaiTop is DSThing {&#13;
    SaiVox   public  vox;&#13;
    SaiTub   public  tub;&#13;
    SaiTap   public  tap;&#13;
&#13;
    DSToken  public  sai;&#13;
    DSToken  public  sin;&#13;
    DSToken  public  skr;&#13;
    ERC20    public  gem;&#13;
&#13;
    uint256  public  fix;  // sai cage price (gem per sai)&#13;
    uint256  public  fit;  // skr cage price (ref per skr)&#13;
    uint256  public  caged;&#13;
    uint256  public  cooldown = 6 hours;&#13;
&#13;
    function SaiTop(SaiTub tub_, SaiTap tap_) public {&#13;
        tub = tub_;&#13;
        tap = tap_;&#13;
&#13;
        vox = tub.vox();&#13;
&#13;
        sai = tub.sai();&#13;
        sin = tub.sin();&#13;
        skr = tub.skr();&#13;
        gem = tub.gem();&#13;
    }&#13;
&#13;
    function era() public view returns (uint) {&#13;
        return block.timestamp;&#13;
    }&#13;
&#13;
    // force settlement of the system at a given price (sai per gem).&#13;
    // This is nearly the equivalent of biting all cups at once.&#13;
    // Important consideration: the gems associated with free skr can&#13;
    // be tapped to make sai whole.&#13;
    function cage(uint price) internal {&#13;
        require(!tub.off() &amp;&amp; price != 0);&#13;
        caged = era();&#13;
&#13;
        tub.drip();  // collect remaining fees&#13;
        tap.heal();  // absorb any pending fees&#13;
&#13;
        fit = rmul(wmul(price, vox.par()), tub.per());&#13;
        // Most gems we can get per sai is the full balance of the tub.&#13;
        // If there is no sai issued, we should still be able to cage.&#13;
        if (sai.totalSupply() == 0) {&#13;
            fix = rdiv(WAD, price);&#13;
        } else {&#13;
            fix = min(rdiv(WAD, price), rdiv(tub.pie(), sai.totalSupply()));&#13;
        }&#13;
&#13;
        tub.cage(fit, rmul(fix, sai.totalSupply()));&#13;
        tap.cage(fix);&#13;
&#13;
        tap.vent();    // burn pending sale skr&#13;
    }&#13;
    // cage by reading the last value from the feed for the price&#13;
    function cage() public note auth {&#13;
        cage(rdiv(uint(tub.pip().read()), vox.par()));&#13;
    }&#13;
&#13;
    function flow() public note {&#13;
        require(tub.off());&#13;
        var empty = tub.din() == 0 &amp;&amp; tap.fog() == 0;&#13;
        var ended = era() &gt; caged + cooldown;&#13;
        require(empty || ended);&#13;
        tub.flow();&#13;
    }&#13;
&#13;
    function setCooldown(uint cooldown_) public auth {&#13;
        cooldown = cooldown_;&#13;
    }&#13;
}&#13;
&#13;
////// src/mom.sol&#13;
/// mom.sol -- admin manager&#13;
&#13;
// Copyright (C) 2017  Nikolai Mushegian &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="2947404246454840694d485959415c4b074a4644">[email protected]</a>&gt;&#13;
// Copyright (C) 2017  Daniel Brockman &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="93f7f2fdfaf6ffd3f7f2e3e3fbe6f1bdf0fcfe">[email protected]</a>&gt;&#13;
// Copyright (C) 2017  Rain &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="a0d2c1c9cec2d2c5c1cbe0d2c9d3c5d5d08ecec5d4">[email protected]</a>&gt;&#13;
&#13;
// This program is free software: you can redistribute it and/or modify&#13;
// it under the terms of the GNU General Public License as published by&#13;
// the Free Software Foundation, either version 3 of the License, or&#13;
// (at your option) any later version.&#13;
&#13;
// This program is distributed in the hope that it will be useful,&#13;
// but WITHOUT ANY WARRANTY; without even the implied warranty of&#13;
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the&#13;
// GNU General Public License for more details.&#13;
&#13;
// You should have received a copy of the GNU General Public License&#13;
// along with this program.  If not, see &lt;http://www.gnu.org/licenses/&gt;.&#13;
&#13;
/* pragma solidity ^0.4.18; */&#13;
&#13;
/* import 'ds-thing/thing.sol'; */&#13;
/* import './tub.sol'; */&#13;
/* import './top.sol'; */&#13;
/* import './tap.sol'; */&#13;
&#13;
contract SaiMom is DSThing {&#13;
    SaiTub  public  tub;&#13;
    SaiTap  public  tap;&#13;
    SaiVox  public  vox;&#13;
&#13;
    function SaiMom(SaiTub tub_, SaiTap tap_, SaiVox vox_) public {&#13;
        tub = tub_;&#13;
        tap = tap_;&#13;
        vox = vox_;&#13;
    }&#13;
    // Debt ceiling&#13;
    function setCap(uint wad) public note auth {&#13;
        tub.mold("cap", wad);&#13;
    }&#13;
    // Liquidation ratio&#13;
    function setMat(uint ray) public note auth {&#13;
        tub.mold("mat", ray);&#13;
        var axe = tub.axe();&#13;
        var mat = tub.mat();&#13;
        require(axe &gt;= RAY &amp;&amp; axe &lt;= mat);&#13;
    }&#13;
    // Stability fee&#13;
    function setTax(uint ray) public note auth {&#13;
        tub.mold("tax", ray);&#13;
        var tax = tub.tax();&#13;
        require(RAY &lt;= tax);&#13;
        require(tax &lt; 10002 * 10 ** 23);  // ~200% per hour&#13;
    }&#13;
    // Governance fee&#13;
    function setFee(uint ray) public note auth {&#13;
        tub.mold("fee", ray);&#13;
        var fee = tub.fee();&#13;
        require(RAY &lt;= fee);&#13;
        require(fee &lt; 10002 * 10 ** 23);  // ~200% per hour&#13;
    }&#13;
    // Liquidation fee&#13;
    function setAxe(uint ray) public note auth {&#13;
        tub.mold("axe", ray);&#13;
        var axe = tub.axe();&#13;
        var mat = tub.mat();&#13;
        require(axe &gt;= RAY &amp;&amp; axe &lt;= mat);&#13;
    }&#13;
    // Join/Exit Spread&#13;
    function setTubGap(uint wad) public note auth {&#13;
        tub.mold("gap", wad);&#13;
    }&#13;
    // ETH/USD Feed&#13;
    function setPip(DSValue pip_) public note auth {&#13;
        tub.setPip(pip_);&#13;
    }&#13;
    // MKR/USD Feed&#13;
    function setPep(DSValue pep_) public note auth {&#13;
        tub.setPep(pep_);&#13;
    }&#13;
    // TRFM&#13;
    function setVox(SaiVox vox_) public note auth {&#13;
        tub.setVox(vox_);&#13;
    }&#13;
    // Boom/Bust Spread&#13;
    function setTapGap(uint wad) public note auth {&#13;
        tap.mold("gap", wad);&#13;
        var gap = tap.gap();&#13;
        require(gap &lt;= 1.05 ether);&#13;
        require(gap &gt;= 0.95 ether);&#13;
    }&#13;
    // Rate of change of target price (per second)&#13;
    function setWay(uint ray) public note auth {&#13;
        require(ray &lt; 10002 * 10 ** 23);  // ~200% per hour&#13;
        require(ray &gt; 9998 * 10 ** 23);&#13;
        vox.mold("way", ray);&#13;
    }&#13;
    function setHow(uint ray) public note auth {&#13;
        vox.tune(ray);&#13;
    }&#13;
}&#13;
&#13;
////// src/fab.sol&#13;
/* pragma solidity ^0.4.18; */&#13;
&#13;
/* import "ds-auth/auth.sol"; */&#13;
/* import 'ds-token/token.sol'; */&#13;
/* import 'ds-guard/guard.sol'; */&#13;
/* import 'ds-roles/roles.sol'; */&#13;
/* import 'ds-value/value.sol'; */&#13;
&#13;
/* import './mom.sol'; */&#13;
&#13;
contract GemFab {&#13;
    function newTok(bytes32 name) public returns (DSToken token) {&#13;
        token = new DSToken(name);&#13;
        token.setOwner(msg.sender);&#13;
    }&#13;
}&#13;
&#13;
contract VoxFab {&#13;
    function newVox() public returns (SaiVox vox) {&#13;
        vox = new SaiVox(10 ** 27);&#13;
        vox.setOwner(msg.sender);&#13;
    }&#13;
}&#13;
&#13;
contract TubFab {&#13;
    function newTub(DSToken sai, DSToken sin, DSToken skr, ERC20 gem, DSToken gov, DSValue pip, DSValue pep, SaiVox vox, address pit) public returns (SaiTub tub) {&#13;
        tub = new SaiTub(sai, sin, skr, gem, gov, pip, pep, vox, pit);&#13;
        tub.setOwner(msg.sender);&#13;
    }&#13;
}&#13;
&#13;
contract TapFab {&#13;
    function newTap(SaiTub tub) public returns (SaiTap tap) {&#13;
        tap = new SaiTap(tub);&#13;
        tap.setOwner(msg.sender);&#13;
    }&#13;
}&#13;
&#13;
contract TopFab {&#13;
    function newTop(SaiTub tub, SaiTap tap) public returns (SaiTop top) {&#13;
        top = new SaiTop(tub, tap);&#13;
        top.setOwner(msg.sender);&#13;
    }&#13;
}&#13;
&#13;
contract MomFab {&#13;
    function newMom(SaiTub tub, SaiTap tap, SaiVox vox) public returns (SaiMom mom) {&#13;
        mom = new SaiMom(tub, tap, vox);&#13;
        mom.setOwner(msg.sender);&#13;
    }&#13;
}&#13;
&#13;
contract DadFab {&#13;
    function newDad() public returns (DSGuard dad) {&#13;
        dad = new DSGuard();&#13;
        dad.setOwner(msg.sender);&#13;
    }&#13;
}&#13;
&#13;
contract DaiFab is DSAuth {&#13;
    GemFab public gemFab;&#13;
    VoxFab public voxFab;&#13;
    TapFab public tapFab;&#13;
    TubFab public tubFab;&#13;
    TopFab public topFab;&#13;
    MomFab public momFab;&#13;
    DadFab public dadFab;&#13;
&#13;
    DSToken public sai;&#13;
    DSToken public sin;&#13;
    DSToken public skr;&#13;
&#13;
    SaiVox public vox;&#13;
    SaiTub public tub;&#13;
    SaiTap public tap;&#13;
    SaiTop public top;&#13;
&#13;
    SaiMom public mom;&#13;
    DSGuard public dad;&#13;
&#13;
    uint8 public step = 0;&#13;
&#13;
    function DaiFab(GemFab gemFab_, VoxFab voxFab_, TubFab tubFab_, TapFab tapFab_, TopFab topFab_, MomFab momFab_, DadFab dadFab_) public {&#13;
        gemFab = gemFab_;&#13;
        voxFab = voxFab_;&#13;
        tubFab = tubFab_;&#13;
        tapFab = tapFab_;&#13;
        topFab = topFab_;&#13;
        momFab = momFab_;&#13;
        dadFab = dadFab_;&#13;
    }&#13;
&#13;
    function makeTokens() public auth {&#13;
        require(step == 0);&#13;
        sai = gemFab.newTok('sai');&#13;
        sin = gemFab.newTok('sin');&#13;
        skr = gemFab.newTok('skr');&#13;
        step += 1;&#13;
    }&#13;
&#13;
    function makeVoxTub(ERC20 gem, DSToken gov, DSValue pip, DSValue pep, address pit) public auth {&#13;
        require(step == 1);&#13;
        require(address(gem) != 0x0);&#13;
        require(address(gov) != 0x0);&#13;
        require(address(pip) != 0x0);&#13;
        require(address(pep) != 0x0);&#13;
        require(pit != 0x0);&#13;
        vox = voxFab.newVox();&#13;
        tub = tubFab.newTub(sai, sin, skr, gem, gov, pip, pep, vox, pit);&#13;
        step += 1;&#13;
    }&#13;
&#13;
    function makeTapTop() public auth {&#13;
        require(step == 2);&#13;
        tap = tapFab.newTap(tub);&#13;
        tub.turn(tap);&#13;
        top = topFab.newTop(tub, tap);&#13;
        step += 1;&#13;
    }&#13;
&#13;
    function S(string s) internal pure returns (bytes4) {&#13;
        return bytes4(keccak256(s));&#13;
    }&#13;
&#13;
    function ray(uint256 wad) internal pure returns (uint256) {&#13;
        return wad * 10 ** 9;&#13;
    }&#13;
&#13;
    // Liquidation Ratio   150%&#13;
    // Liquidation Penalty 13%&#13;
    // Stability Fee       0.05%&#13;
    // PETH Fee            0%&#13;
    // Boom/Bust Spread   -3%&#13;
    // Join/Exit Spread    0%&#13;
    // Debt Ceiling        0&#13;
    function configParams() public auth {&#13;
        require(step == 3);&#13;
&#13;
        tub.mold("cap", 0);&#13;
        tub.mold("mat", ray(1.5  ether));&#13;
        tub.mold("axe", ray(1.13 ether));&#13;
        tub.mold("fee", 1000000000158153903837946257);  // 0.5% / year&#13;
        tub.mold("tax", ray(1 ether));&#13;
        tub.mold("gap", 1 ether);&#13;
&#13;
        tap.mold("gap", 0.97 ether);&#13;
&#13;
        step += 1;&#13;
    }&#13;
&#13;
    function verifyParams() public auth {&#13;
        require(step == 4);&#13;
&#13;
        require(tub.cap() == 0);&#13;
        require(tub.mat() == 1500000000000000000000000000);&#13;
        require(tub.axe() == 1130000000000000000000000000);&#13;
        require(tub.fee() == 1000000000158153903837946257);&#13;
        require(tub.tax() == 1000000000000000000000000000);&#13;
        require(tub.gap() == 1000000000000000000);&#13;
&#13;
        require(tap.gap() == 970000000000000000);&#13;
&#13;
        require(vox.par() == 1000000000000000000000000000);&#13;
        require(vox.how() == 0);&#13;
&#13;
        step += 1;&#13;
    }&#13;
&#13;
    function configAuth(DSAuthority authority) public auth {&#13;
        require(step == 5);&#13;
        require(address(authority) != 0x0);&#13;
&#13;
        mom = momFab.newMom(tub, tap, vox);&#13;
        dad = dadFab.newDad();&#13;
&#13;
        vox.setAuthority(dad);&#13;
        vox.setOwner(0);&#13;
        tub.setAuthority(dad);&#13;
        tub.setOwner(0);&#13;
        tap.setAuthority(dad);&#13;
        tap.setOwner(0);&#13;
        sai.setAuthority(dad);&#13;
        sai.setOwner(0);&#13;
        sin.setAuthority(dad);&#13;
        sin.setOwner(0);&#13;
        skr.setAuthority(dad);&#13;
        skr.setOwner(0);&#13;
&#13;
        top.setAuthority(authority);&#13;
        top.setOwner(0);&#13;
        mom.setAuthority(authority);&#13;
        mom.setOwner(0);&#13;
&#13;
        dad.permit(top, tub, S("cage(uint256,uint256)"));&#13;
        dad.permit(top, tub, S("flow()"));&#13;
        dad.permit(top, tap, S("cage(uint256)"));&#13;
&#13;
        dad.permit(tub, skr, S('mint(address,uint256)'));&#13;
        dad.permit(tub, skr, S('burn(address,uint256)'));&#13;
&#13;
        dad.permit(tub, sai, S('mint(address,uint256)'));&#13;
        dad.permit(tub, sai, S('burn(address,uint256)'));&#13;
&#13;
        dad.permit(tub, sin, S('mint(address,uint256)'));&#13;
&#13;
        dad.permit(tap, sai, S('mint(address,uint256)'));&#13;
        dad.permit(tap, sai, S('burn(address,uint256)'));&#13;
        dad.permit(tap, sai, S('burn(uint256)'));&#13;
        dad.permit(tap, sin, S('burn(uint256)'));&#13;
&#13;
        dad.permit(tap, skr, S('mint(uint256)'));&#13;
        dad.permit(tap, skr, S('burn(uint256)'));&#13;
        dad.permit(tap, skr, S('burn(address,uint256)'));&#13;
&#13;
        dad.permit(mom, vox, S("mold(bytes32,uint256)"));&#13;
        dad.permit(mom, vox, S("tune(uint256)"));&#13;
        dad.permit(mom, tub, S("mold(bytes32,uint256)"));&#13;
        dad.permit(mom, tap, S("mold(bytes32,uint256)"));&#13;
        dad.permit(mom, tub, S("setPip(address)"));&#13;
        dad.permit(mom, tub, S("setPep(address)"));&#13;
        dad.permit(mom, tub, S("setVox(address)"));&#13;
&#13;
        dad.setOwner(0);&#13;
        step += 1;&#13;
    }&#13;
}