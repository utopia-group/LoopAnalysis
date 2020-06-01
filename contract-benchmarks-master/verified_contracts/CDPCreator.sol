pragma solidity ^0.4.24;
// hevm: flattened sources of src/tub.sol


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

/*  */

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

/*  */

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

/*  */

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

/*  */

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

/*  */

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

/*  */

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

/*  */

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

/*  */

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

/*  */

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

// Copyright (C) 2016, 2017  Nikolai Mushegian <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="84eaedefebe8e5edc4e0e5f4f4ecf1e6aae7ebe9">[email protected]</a>&gt;&#13;
// Copyright (C) 2016, 2017  Daniel Brockman &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="7c181d121519103c181d0c0c14091e521f1311">[email protected]</a>&gt;&#13;
// Copyright (C) 2017        Rain Break &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="b1c3d0d8dfd3c3d4d0daf1c3d8c2d4c4c19fdfd4c5">[email protected]</a>&gt;&#13;
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
/*  */&#13;
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
// Copyright (C) 2017  Nikolai Mushegian &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="0d63646662616c644d696c7d7d65786f236e6260">[email protected]</a>&gt;&#13;
// Copyright (C) 2017  Daniel Brockman &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="afcbcec1c6cac3efcbcedfdfc7dacd81ccc0c2">[email protected]</a>&gt;&#13;
// Copyright (C) 2017  Rain Break &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="e19380888f839384808aa1938892849491cf8f8495">[email protected]</a>&gt;&#13;
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
/*  */&#13;
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
// Copyright (C) 2015, 2016, 2017 Dapphub&#13;
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
&#13;
&#13;
contract WETH9 {&#13;
    string public name     = "Wrapped Ether";&#13;
    string public symbol   = "WETH";&#13;
    uint8  public decimals = 18;&#13;
&#13;
    event  Approval(address indexed src, address indexed guy, uint wad);&#13;
    event  Transfer(address indexed src, address indexed dst, uint wad);&#13;
    event  Deposit(address indexed dst, uint wad);&#13;
    event  Withdrawal(address indexed src, uint wad);&#13;
&#13;
    mapping (address =&gt; uint)                       public  balanceOf;&#13;
    mapping (address =&gt; mapping (address =&gt; uint))  public  allowance;&#13;
&#13;
    function() public payable {&#13;
        deposit();&#13;
    }&#13;
    function deposit() public payable {&#13;
        balanceOf[msg.sender] += msg.value;&#13;
        Deposit(msg.sender, msg.value);&#13;
    }&#13;
    function withdraw(uint wad) public {&#13;
        require(balanceOf[msg.sender] &gt;= wad);&#13;
        balanceOf[msg.sender] -= wad;&#13;
        msg.sender.transfer(wad);&#13;
        Withdrawal(msg.sender, wad);&#13;
    }&#13;
&#13;
    function totalSupply() public view returns (uint) {&#13;
        return this.balance;&#13;
    }&#13;
&#13;
    function approve(address guy, uint wad) public returns (bool) {&#13;
        allowance[msg.sender][guy] = wad;&#13;
        Approval(msg.sender, guy, wad);&#13;
        return true;&#13;
    }&#13;
&#13;
    function transfer(address dst, uint wad) public returns (bool) {&#13;
        return transferFrom(msg.sender, dst, wad);&#13;
    }&#13;
&#13;
    function transferFrom(address src, address dst, uint wad)&#13;
        public&#13;
        returns (bool)&#13;
    {&#13;
        require(balanceOf[src] &gt;= wad);&#13;
&#13;
        if (src != msg.sender &amp;&amp; allowance[src][msg.sender] != uint(-1)) {&#13;
            require(allowance[src][msg.sender] &gt;= wad);&#13;
            allowance[src][msg.sender] -= wad;&#13;
        }&#13;
&#13;
        balanceOf[src] -= wad;&#13;
        balanceOf[dst] += wad;&#13;
&#13;
        Transfer(src, dst, wad);&#13;
&#13;
        return true;&#13;
    }&#13;
}&#13;
&#13;
&#13;
/*&#13;
                    GNU GENERAL PUBLIC LICENSE&#13;
                       Version 3, 29 June 2007&#13;
&#13;
 Copyright (C) 2007 Free Software Foundation, Inc. &lt;http://fsf.org/&gt;&#13;
 Everyone is permitted to copy and distribute verbatim copies&#13;
 of this license document, but changing it is not allowed.&#13;
&#13;
                            Preamble&#13;
&#13;
  The GNU General Public License is a free, copyleft license for&#13;
software and other kinds of works.&#13;
&#13;
  The licenses for most software and other practical works are designed&#13;
to take away your freedom to share and change the works.  By contrast,&#13;
the GNU General Public License is intended to guarantee your freedom to&#13;
share and change all versions of a program--to make sure it remains free&#13;
software for all its users.  We, the Free Software Foundation, use the&#13;
GNU General Public License for most of our software; it applies also to&#13;
any other work released this way by its authors.  You can apply it to&#13;
your programs, too.&#13;
&#13;
  When we speak of free software, we are referring to freedom, not&#13;
price.  Our General Public Licenses are designed to make sure that you&#13;
have the freedom to distribute copies of free software (and charge for&#13;
them if you wish), that you receive source code or can get it if you&#13;
want it, that you can change the software or use pieces of it in new&#13;
free programs, and that you know you can do these things.&#13;
&#13;
  To protect your rights, we need to prevent others from denying you&#13;
these rights or asking you to surrender the rights.  Therefore, you have&#13;
certain responsibilities if you distribute copies of the software, or if&#13;
you modify it: responsibilities to respect the freedom of others.&#13;
&#13;
  For example, if you distribute copies of such a program, whether&#13;
gratis or for a fee, you must pass on to the recipients the same&#13;
freedoms that you received.  You must make sure that they, too, receive&#13;
or can get the source code.  And you must show them these terms so they&#13;
know their rights.&#13;
&#13;
  Developers that use the GNU GPL protect your rights with two steps:&#13;
(1) assert copyright on the software, and (2) offer you this License&#13;
giving you legal permission to copy, distribute and/or modify it.&#13;
&#13;
  For the developers' and authors' protection, the GPL clearly explains&#13;
that there is no warranty for this free software.  For both users' and&#13;
authors' sake, the GPL requires that modified versions be marked as&#13;
changed, so that their problems will not be attributed erroneously to&#13;
authors of previous versions.&#13;
&#13;
  Some devices are designed to deny users access to install or run&#13;
modified versions of the software inside them, although the manufacturer&#13;
can do so.  This is fundamentally incompatible with the aim of&#13;
protecting users' freedom to change the software.  The systematic&#13;
pattern of such abuse occurs in the area of products for individuals to&#13;
use, which is precisely where it is most unacceptable.  Therefore, we&#13;
have designed this version of the GPL to prohibit the practice for those&#13;
products.  If such problems arise substantially in other domains, we&#13;
stand ready to extend this provision to those domains in future versions&#13;
of the GPL, as needed to protect the freedom of users.&#13;
&#13;
  Finally, every program is threatened constantly by software patents.&#13;
States should not allow patents to restrict development and use of&#13;
software on general-purpose computers, but in those that do, we wish to&#13;
avoid the special danger that patents applied to a free program could&#13;
make it effectively proprietary.  To prevent this, the GPL assures that&#13;
patents cannot be used to render the program non-free.&#13;
&#13;
  The precise terms and conditions for copying, distribution and&#13;
modification follow.&#13;
&#13;
                       TERMS AND CONDITIONS&#13;
&#13;
  0. Definitions.&#13;
&#13;
  "This License" refers to version 3 of the GNU General Public License.&#13;
&#13;
  "Copyright" also means copyright-like laws that apply to other kinds of&#13;
works, such as semiconductor masks.&#13;
&#13;
  "The Program" refers to any copyrightable work licensed under this&#13;
License.  Each licensee is addressed as "you".  "Licensees" and&#13;
"recipients" may be individuals or organizations.&#13;
&#13;
  To "modify" a work means to copy from or adapt all or part of the work&#13;
in a fashion requiring copyright permission, other than the making of an&#13;
exact copy.  The resulting work is called a "modified version" of the&#13;
earlier work or a work "based on" the earlier work.&#13;
&#13;
  A "covered work" means either the unmodified Program or a work based&#13;
on the Program.&#13;
&#13;
  To "propagate" a work means to do anything with it that, without&#13;
permission, would make you directly or secondarily liable for&#13;
infringement under applicable copyright law, except executing it on a&#13;
computer or modifying a private copy.  Propagation includes copying,&#13;
distribution (with or without modification), making available to the&#13;
public, and in some countries other activities as well.&#13;
&#13;
  To "convey" a work means any kind of propagation that enables other&#13;
parties to make or receive copies.  Mere interaction with a user through&#13;
a computer network, with no transfer of a copy, is not conveying.&#13;
&#13;
  An interactive user interface displays "Appropriate Legal Notices"&#13;
to the extent that it includes a convenient and prominently visible&#13;
feature that (1) displays an appropriate copyright notice, and (2)&#13;
tells the user that there is no warranty for the work (except to the&#13;
extent that warranties are provided), that licensees may convey the&#13;
work under this License, and how to view a copy of this License.  If&#13;
the interface presents a list of user commands or options, such as a&#13;
menu, a prominent item in the list meets this criterion.&#13;
&#13;
  1. Source Code.&#13;
&#13;
  The "source code" for a work means the preferred form of the work&#13;
for making modifications to it.  "Object code" means any non-source&#13;
form of a work.&#13;
&#13;
  A "Standard Interface" means an interface that either is an official&#13;
standard defined by a recognized standards body, or, in the case of&#13;
interfaces specified for a particular programming language, one that&#13;
is widely used among developers working in that language.&#13;
&#13;
  The "System Libraries" of an executable work include anything, other&#13;
than the work as a whole, that (a) is included in the normal form of&#13;
packaging a Major Component, but which is not part of that Major&#13;
Component, and (b) serves only to enable use of the work with that&#13;
Major Component, or to implement a Standard Interface for which an&#13;
implementation is available to the public in source code form.  A&#13;
"Major Component", in this context, means a major essential component&#13;
(kernel, window system, and so on) of the specific operating system&#13;
(if any) on which the executable work runs, or a compiler used to&#13;
produce the work, or an object code interpreter used to run it.&#13;
&#13;
  The "Corresponding Source" for a work in object code form means all&#13;
the source code needed to generate, install, and (for an executable&#13;
work) run the object code and to modify the work, including scripts to&#13;
control those activities.  However, it does not include the work's&#13;
System Libraries, or general-purpose tools or generally available free&#13;
programs which are used unmodified in performing those activities but&#13;
which are not part of the work.  For example, Corresponding Source&#13;
includes interface definition files associated with source files for&#13;
the work, and the source code for shared libraries and dynamically&#13;
linked subprograms that the work is specifically designed to require,&#13;
such as by intimate data communication or control flow between those&#13;
subprograms and other parts of the work.&#13;
&#13;
  The Corresponding Source need not include anything that users&#13;
can regenerate automatically from other parts of the Corresponding&#13;
Source.&#13;
&#13;
  The Corresponding Source for a work in source code form is that&#13;
same work.&#13;
&#13;
  2. Basic Permissions.&#13;
&#13;
  All rights granted under this License are granted for the term of&#13;
copyright on the Program, and are irrevocable provided the stated&#13;
conditions are met.  This License explicitly affirms your unlimited&#13;
permission to run the unmodified Program.  The output from running a&#13;
covered work is covered by this License only if the output, given its&#13;
content, constitutes a covered work.  This License acknowledges your&#13;
rights of fair use or other equivalent, as provided by copyright law.&#13;
&#13;
  You may make, run and propagate covered works that you do not&#13;
convey, without conditions so long as your license otherwise remains&#13;
in force.  You may convey covered works to others for the sole purpose&#13;
of having them make modifications exclusively for you, or provide you&#13;
with facilities for running those works, provided that you comply with&#13;
the terms of this License in conveying all material for which you do&#13;
not control copyright.  Those thus making or running the covered works&#13;
for you must do so exclusively on your behalf, under your direction&#13;
and control, on terms that prohibit them from making any copies of&#13;
your copyrighted material outside their relationship with you.&#13;
&#13;
  Conveying under any other circumstances is permitted solely under&#13;
the conditions stated below.  Sublicensing is not allowed; section 10&#13;
makes it unnecessary.&#13;
&#13;
  3. Protecting Users' Legal Rights From Anti-Circumvention Law.&#13;
&#13;
  No covered work shall be deemed part of an effective technological&#13;
measure under any applicable law fulfilling obligations under article&#13;
11 of the WIPO copyright treaty adopted on 20 December 1996, or&#13;
similar laws prohibiting or restricting circumvention of such&#13;
measures.&#13;
&#13;
  When you convey a covered work, you waive any legal power to forbid&#13;
circumvention of technological measures to the extent such circumvention&#13;
is effected by exercising rights under this License with respect to&#13;
the covered work, and you disclaim any intention to limit operation or&#13;
modification of the work as a means of enforcing, against the work's&#13;
users, your or third parties' legal rights to forbid circumvention of&#13;
technological measures.&#13;
&#13;
  4. Conveying Verbatim Copies.&#13;
&#13;
  You may convey verbatim copies of the Program's source code as you&#13;
receive it, in any medium, provided that you conspicuously and&#13;
appropriately publish on each copy an appropriate copyright notice;&#13;
keep intact all notices stating that this License and any&#13;
non-permissive terms added in accord with section 7 apply to the code;&#13;
keep intact all notices of the absence of any warranty; and give all&#13;
recipients a copy of this License along with the Program.&#13;
&#13;
  You may charge any price or no price for each copy that you convey,&#13;
and you may offer support or warranty protection for a fee.&#13;
&#13;
  5. Conveying Modified Source Versions.&#13;
&#13;
  You may convey a work based on the Program, or the modifications to&#13;
produce it from the Program, in the form of source code under the&#13;
terms of section 4, provided that you also meet all of these conditions:&#13;
&#13;
    a) The work must carry prominent notices stating that you modified&#13;
    it, and giving a relevant date.&#13;
&#13;
    b) The work must carry prominent notices stating that it is&#13;
    released under this License and any conditions added under section&#13;
    7.  This requirement modifies the requirement in section 4 to&#13;
    "keep intact all notices".&#13;
&#13;
    c) You must license the entire work, as a whole, under this&#13;
    License to anyone who comes into possession of a copy.  This&#13;
    License will therefore apply, along with any applicable section 7&#13;
    additional terms, to the whole of the work, and all its parts,&#13;
    regardless of how they are packaged.  This License gives no&#13;
    permission to license the work in any other way, but it does not&#13;
    invalidate such permission if you have separately received it.&#13;
&#13;
    d) If the work has interactive user interfaces, each must display&#13;
    Appropriate Legal Notices; however, if the Program has interactive&#13;
    interfaces that do not display Appropriate Legal Notices, your&#13;
    work need not make them do so.&#13;
&#13;
  A compilation of a covered work with other separate and independent&#13;
works, which are not by their nature extensions of the covered work,&#13;
and which are not combined with it such as to form a larger program,&#13;
in or on a volume of a storage or distribution medium, is called an&#13;
"aggregate" if the compilation and its resulting copyright are not&#13;
used to limit the access or legal rights of the compilation's users&#13;
beyond what the individual works permit.  Inclusion of a covered work&#13;
in an aggregate does not cause this License to apply to the other&#13;
parts of the aggregate.&#13;
&#13;
  6. Conveying Non-Source Forms.&#13;
&#13;
  You may convey a covered work in object code form under the terms&#13;
of sections 4 and 5, provided that you also convey the&#13;
machine-readable Corresponding Source under the terms of this License,&#13;
in one of these ways:&#13;
&#13;
    a) Convey the object code in, or embodied in, a physical product&#13;
    (including a physical distribution medium), accompanied by the&#13;
    Corresponding Source fixed on a durable physical medium&#13;
    customarily used for software interchange.&#13;
&#13;
    b) Convey the object code in, or embodied in, a physical product&#13;
    (including a physical distribution medium), accompanied by a&#13;
    written offer, valid for at least three years and valid for as&#13;
    long as you offer spare parts or customer support for that product&#13;
    model, to give anyone who possesses the object code either (1) a&#13;
    copy of the Corresponding Source for all the software in the&#13;
    product that is covered by this License, on a durable physical&#13;
    medium customarily used for software interchange, for a price no&#13;
    more than your reasonable cost of physically performing this&#13;
    conveying of source, or (2) access to copy the&#13;
    Corresponding Source from a network server at no charge.&#13;
&#13;
    c) Convey individual copies of the object code with a copy of the&#13;
    written offer to provide the Corresponding Source.  This&#13;
    alternative is allowed only occasionally and noncommercially, and&#13;
    only if you received the object code with such an offer, in accord&#13;
    with subsection 6b.&#13;
&#13;
    d) Convey the object code by offering access from a designated&#13;
    place (gratis or for a charge), and offer equivalent access to the&#13;
    Corresponding Source in the same way through the same place at no&#13;
    further charge.  You need not require recipients to copy the&#13;
    Corresponding Source along with the object code.  If the place to&#13;
    copy the object code is a network server, the Corresponding Source&#13;
    may be on a different server (operated by you or a third party)&#13;
    that supports equivalent copying facilities, provided you maintain&#13;
    clear directions next to the object code saying where to find the&#13;
    Corresponding Source.  Regardless of what server hosts the&#13;
    Corresponding Source, you remain obligated to ensure that it is&#13;
    available for as long as needed to satisfy these requirements.&#13;
&#13;
    e) Convey the object code using peer-to-peer transmission, provided&#13;
    you inform other peers where the object code and Corresponding&#13;
    Source of the work are being offered to the general public at no&#13;
    charge under subsection 6d.&#13;
&#13;
  A separable portion of the object code, whose source code is excluded&#13;
from the Corresponding Source as a System Library, need not be&#13;
included in conveying the object code work.&#13;
&#13;
  A "User Product" is either (1) a "consumer product", which means any&#13;
tangible personal property which is normally used for personal, family,&#13;
or household purposes, or (2) anything designed or sold for incorporation&#13;
into a dwelling.  In determining whether a product is a consumer product,&#13;
doubtful cases shall be resolved in favor of coverage.  For a particular&#13;
product received by a particular user, "normally used" refers to a&#13;
typical or common use of that class of product, regardless of the status&#13;
of the particular user or of the way in which the particular user&#13;
actually uses, or expects or is expected to use, the product.  A product&#13;
is a consumer product regardless of whether the product has substantial&#13;
commercial, industrial or non-consumer uses, unless such uses represent&#13;
the only significant mode of use of the product.&#13;
&#13;
  "Installation Information" for a User Product means any methods,&#13;
procedures, authorization keys, or other information required to install&#13;
and execute modified versions of a covered work in that User Product from&#13;
a modified version of its Corresponding Source.  The information must&#13;
suffice to ensure that the continued functioning of the modified object&#13;
code is in no case prevented or interfered with solely because&#13;
modification has been made.&#13;
&#13;
  If you convey an object code work under this section in, or with, or&#13;
specifically for use in, a User Product, and the conveying occurs as&#13;
part of a transaction in which the right of possession and use of the&#13;
User Product is transferred to the recipient in perpetuity or for a&#13;
fixed term (regardless of how the transaction is characterized), the&#13;
Corresponding Source conveyed under this section must be accompanied&#13;
by the Installation Information.  But this requirement does not apply&#13;
if neither you nor any third party retains the ability to install&#13;
modified object code on the User Product (for example, the work has&#13;
been installed in ROM).&#13;
&#13;
  The requirement to provide Installation Information does not include a&#13;
requirement to continue to provide support service, warranty, or updates&#13;
for a work that has been modified or installed by the recipient, or for&#13;
the User Product in which it has been modified or installed.  Access to a&#13;
network may be denied when the modification itself materially and&#13;
adversely affects the operation of the network or violates the rules and&#13;
protocols for communication across the network.&#13;
&#13;
  Corresponding Source conveyed, and Installation Information provided,&#13;
in accord with this section must be in a format that is publicly&#13;
documented (and with an implementation available to the public in&#13;
source code form), and must require no special password or key for&#13;
unpacking, reading or copying.&#13;
&#13;
  7. Additional Terms.&#13;
&#13;
  "Additional permissions" are terms that supplement the terms of this&#13;
License by making exceptions from one or more of its conditions.&#13;
Additional permissions that are applicable to the entire Program shall&#13;
be treated as though they were included in this License, to the extent&#13;
that they are valid under applicable law.  If additional permissions&#13;
apply only to part of the Program, that part may be used separately&#13;
under those permissions, but the entire Program remains governed by&#13;
this License without regard to the additional permissions.&#13;
&#13;
  When you convey a copy of a covered work, you may at your option&#13;
remove any additional permissions from that copy, or from any part of&#13;
it.  (Additional permissions may be written to require their own&#13;
removal in certain cases when you modify the work.)  You may place&#13;
additional permissions on material, added by you to a covered work,&#13;
for which you have or can give appropriate copyright permission.&#13;
&#13;
  Notwithstanding any other provision of this License, for material you&#13;
add to a covered work, you may (if authorized by the copyright holders of&#13;
that material) supplement the terms of this License with terms:&#13;
&#13;
    a) Disclaiming warranty or limiting liability differently from the&#13;
    terms of sections 15 and 16 of this License; or&#13;
&#13;
    b) Requiring preservation of specified reasonable legal notices or&#13;
    author attributions in that material or in the Appropriate Legal&#13;
    Notices displayed by works containing it; or&#13;
&#13;
    c) Prohibiting misrepresentation of the origin of that material, or&#13;
    requiring that modified versions of such material be marked in&#13;
    reasonable ways as different from the original version; or&#13;
&#13;
    d) Limiting the use for publicity purposes of names of licensors or&#13;
    authors of the material; or&#13;
&#13;
    e) Declining to grant rights under trademark law for use of some&#13;
    trade names, trademarks, or service marks; or&#13;
&#13;
    f) Requiring indemnification of licensors and authors of that&#13;
    material by anyone who conveys the material (or modified versions of&#13;
    it) with contractual assumptions of liability to the recipient, for&#13;
    any liability that these contractual assumptions directly impose on&#13;
    those licensors and authors.&#13;
&#13;
  All other non-permissive additional terms are considered "further&#13;
restrictions" within the meaning of section 10.  If the Program as you&#13;
received it, or any part of it, contains a notice stating that it is&#13;
governed by this License along with a term that is a further&#13;
restriction, you may remove that term.  If a license document contains&#13;
a further restriction but permits relicensing or conveying under this&#13;
License, you may add to a covered work material governed by the terms&#13;
of that license document, provided that the further restriction does&#13;
not survive such relicensing or conveying.&#13;
&#13;
  If you add terms to a covered work in accord with this section, you&#13;
must place, in the relevant source files, a statement of the&#13;
additional terms that apply to those files, or a notice indicating&#13;
where to find the applicable terms.&#13;
&#13;
  Additional terms, permissive or non-permissive, may be stated in the&#13;
form of a separately written license, or stated as exceptions;&#13;
the above requirements apply either way.&#13;
&#13;
  8. Termination.&#13;
&#13;
  You may not propagate or modify a covered work except as expressly&#13;
provided under this License.  Any attempt otherwise to propagate or&#13;
modify it is void, and will automatically terminate your rights under&#13;
this License (including any patent licenses granted under the third&#13;
paragraph of section 11).&#13;
&#13;
  However, if you cease all violation of this License, then your&#13;
license from a particular copyright holder is reinstated (a)&#13;
provisionally, unless and until the copyright holder explicitly and&#13;
finally terminates your license, and (b) permanently, if the copyright&#13;
holder fails to notify you of the violation by some reasonable means&#13;
prior to 60 days after the cessation.&#13;
&#13;
  Moreover, your license from a particular copyright holder is&#13;
reinstated permanently if the copyright holder notifies you of the&#13;
violation by some reasonable means, this is the first time you have&#13;
received notice of violation of this License (for any work) from that&#13;
copyright holder, and you cure the violation prior to 30 days after&#13;
your receipt of the notice.&#13;
&#13;
  Termination of your rights under this section does not terminate the&#13;
licenses of parties who have received copies or rights from you under&#13;
this License.  If your rights have been terminated and not permanently&#13;
reinstated, you do not qualify to receive new licenses for the same&#13;
material under section 10.&#13;
&#13;
  9. Acceptance Not Required for Having Copies.&#13;
&#13;
  You are not required to accept this License in order to receive or&#13;
run a copy of the Program.  Ancillary propagation of a covered work&#13;
occurring solely as a consequence of using peer-to-peer transmission&#13;
to receive a copy likewise does not require acceptance.  However,&#13;
nothing other than this License grants you permission to propagate or&#13;
modify any covered work.  These actions infringe copyright if you do&#13;
not accept this License.  Therefore, by modifying or propagating a&#13;
covered work, you indicate your acceptance of this License to do so.&#13;
&#13;
  10. Automatic Licensing of Downstream Recipients.&#13;
&#13;
  Each time you convey a covered work, the recipient automatically&#13;
receives a license from the original licensors, to run, modify and&#13;
propagate that work, subject to this License.  You are not responsible&#13;
for enforcing compliance by third parties with this License.&#13;
&#13;
  An "entity transaction" is a transaction transferring control of an&#13;
organization, or substantially all assets of one, or subdividing an&#13;
organization, or merging organizations.  If propagation of a covered&#13;
work results from an entity transaction, each party to that&#13;
transaction who receives a copy of the work also receives whatever&#13;
licenses to the work the party's predecessor in interest had or could&#13;
give under the previous paragraph, plus a right to possession of the&#13;
Corresponding Source of the work from the predecessor in interest, if&#13;
the predecessor has it or can get it with reasonable efforts.&#13;
&#13;
  You may not impose any further restrictions on the exercise of the&#13;
rights granted or affirmed under this License.  For example, you may&#13;
not impose a license fee, royalty, or other charge for exercise of&#13;
rights granted under this License, and you may not initiate litigation&#13;
(including a cross-claim or counterclaim in a lawsuit) alleging that&#13;
any patent claim is infringed by making, using, selling, offering for&#13;
sale, or importing the Program or any portion of it.&#13;
&#13;
  11. Patents.&#13;
&#13;
  A "contributor" is a copyright holder who authorizes use under this&#13;
License of the Program or a work on which the Program is based.  The&#13;
work thus licensed is called the contributor's "contributor version".&#13;
&#13;
  A contributor's "essential patent claims" are all patent claims&#13;
owned or controlled by the contributor, whether already acquired or&#13;
hereafter acquired, that would be infringed by some manner, permitted&#13;
by this License, of making, using, or selling its contributor version,&#13;
but do not include claims that would be infringed only as a&#13;
consequence of further modification of the contributor version.  For&#13;
purposes of this definition, "control" includes the right to grant&#13;
patent sublicenses in a manner consistent with the requirements of&#13;
this License.&#13;
&#13;
  Each contributor grants you a non-exclusive, worldwide, royalty-free&#13;
patent license under the contributor's essential patent claims, to&#13;
make, use, sell, offer for sale, import and otherwise run, modify and&#13;
propagate the contents of its contributor version.&#13;
&#13;
  In the following three paragraphs, a "patent license" is any express&#13;
agreement or commitment, however denominated, not to enforce a patent&#13;
(such as an express permission to practice a patent or covenant not to&#13;
sue for patent infringement).  To "grant" such a patent license to a&#13;
party means to make such an agreement or commitment not to enforce a&#13;
patent against the party.&#13;
&#13;
  If you convey a covered work, knowingly relying on a patent license,&#13;
and the Corresponding Source of the work is not available for anyone&#13;
to copy, free of charge and under the terms of this License, through a&#13;
publicly available network server or other readily accessible means,&#13;
then you must either (1) cause the Corresponding Source to be so&#13;
available, or (2) arrange to deprive yourself of the benefit of the&#13;
patent license for this particular work, or (3) arrange, in a manner&#13;
consistent with the requirements of this License, to extend the patent&#13;
license to downstream recipients.  "Knowingly relying" means you have&#13;
actual knowledge that, but for the patent license, your conveying the&#13;
covered work in a country, or your recipient's use of the covered work&#13;
in a country, would infringe one or more identifiable patents in that&#13;
country that you have reason to believe are valid.&#13;
&#13;
  If, pursuant to or in connection with a single transaction or&#13;
arrangement, you convey, or propagate by procuring conveyance of, a&#13;
covered work, and grant a patent license to some of the parties&#13;
receiving the covered work authorizing them to use, propagate, modify&#13;
or convey a specific copy of the covered work, then the patent license&#13;
you grant is automatically extended to all recipients of the covered&#13;
work and works based on it.&#13;
&#13;
  A patent license is "discriminatory" if it does not include within&#13;
the scope of its coverage, prohibits the exercise of, or is&#13;
conditioned on the non-exercise of one or more of the rights that are&#13;
specifically granted under this License.  You may not convey a covered&#13;
work if you are a party to an arrangement with a third party that is&#13;
in the business of distributing software, under which you make payment&#13;
to the third party based on the extent of your activity of conveying&#13;
the work, and under which the third party grants, to any of the&#13;
parties who would receive the covered work from you, a discriminatory&#13;
patent license (a) in connection with copies of the covered work&#13;
conveyed by you (or copies made from those copies), or (b) primarily&#13;
for and in connection with specific products or compilations that&#13;
contain the covered work, unless you entered into that arrangement,&#13;
or that patent license was granted, prior to 28 March 2007.&#13;
&#13;
  Nothing in this License shall be construed as excluding or limiting&#13;
any implied license or other defenses to infringement that may&#13;
otherwise be available to you under applicable patent law.&#13;
&#13;
  12. No Surrender of Others' Freedom.&#13;
&#13;
  If conditions are imposed on you (whether by court order, agreement or&#13;
otherwise) that contradict the conditions of this License, they do not&#13;
excuse you from the conditions of this License.  If you cannot convey a&#13;
covered work so as to satisfy simultaneously your obligations under this&#13;
License and any other pertinent obligations, then as a consequence you may&#13;
not convey it at all.  For example, if you agree to terms that obligate you&#13;
to collect a royalty for further conveying from those to whom you convey&#13;
the Program, the only way you could satisfy both those terms and this&#13;
License would be to refrain entirely from conveying the Program.&#13;
&#13;
  13. Use with the GNU Affero General Public License.&#13;
&#13;
  Notwithstanding any other provision of this License, you have&#13;
permission to link or combine any covered work with a work licensed&#13;
under version 3 of the GNU Affero General Public License into a single&#13;
combined work, and to convey the resulting work.  The terms of this&#13;
License will continue to apply to the part which is the covered work,&#13;
but the special requirements of the GNU Affero General Public License,&#13;
section 13, concerning interaction through a network will apply to the&#13;
combination as such.&#13;
&#13;
  14. Revised Versions of this License.&#13;
&#13;
  The Free Software Foundation may publish revised and/or new versions of&#13;
the GNU General Public License from time to time.  Such new versions will&#13;
be similar in spirit to the present version, but may differ in detail to&#13;
address new problems or concerns.&#13;
&#13;
  Each version is given a distinguishing version number.  If the&#13;
Program specifies that a certain numbered version of the GNU General&#13;
Public License "or any later version" applies to it, you have the&#13;
option of following the terms and conditions either of that numbered&#13;
version or of any later version published by the Free Software&#13;
Foundation.  If the Program does not specify a version number of the&#13;
GNU General Public License, you may choose any version ever published&#13;
by the Free Software Foundation.&#13;
&#13;
  If the Program specifies that a proxy can decide which future&#13;
versions of the GNU General Public License can be used, that proxy's&#13;
public statement of acceptance of a version permanently authorizes you&#13;
to choose that version for the Program.&#13;
&#13;
  Later license versions may give you additional or different&#13;
permissions.  However, no additional obligations are imposed on any&#13;
author or copyright holder as a result of your choosing to follow a&#13;
later version.&#13;
&#13;
  15. Disclaimer of Warranty.&#13;
&#13;
  THERE IS NO WARRANTY FOR THE PROGRAM, TO THE EXTENT PERMITTED BY&#13;
APPLICABLE LAW.  EXCEPT WHEN OTHERWISE STATED IN WRITING THE COPYRIGHT&#13;
HOLDERS AND/OR OTHER PARTIES PROVIDE THE PROGRAM "AS IS" WITHOUT WARRANTY&#13;
OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO,&#13;
THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR&#13;
PURPOSE.  THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE PROGRAM&#13;
IS WITH YOU.  SHOULD THE PROGRAM PROVE DEFECTIVE, YOU ASSUME THE COST OF&#13;
ALL NECESSARY SERVICING, REPAIR OR CORRECTION.&#13;
&#13;
  16. Limitation of Liability.&#13;
&#13;
  IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING&#13;
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MODIFIES AND/OR CONVEYS&#13;
THE PROGRAM AS PERMITTED ABOVE, BE LIABLE TO YOU FOR DAMAGES, INCLUDING ANY&#13;
GENERAL, SPECIAL, INCIDENTAL OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE&#13;
USE OR INABILITY TO USE THE PROGRAM (INCLUDING BUT NOT LIMITED TO LOSS OF&#13;
DATA OR DATA BEING RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD&#13;
PARTIES OR A FAILURE OF THE PROGRAM TO OPERATE WITH ANY OTHER PROGRAMS),&#13;
EVEN IF SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF&#13;
SUCH DAMAGES.&#13;
&#13;
  17. Interpretation of Sections 15 and 16.&#13;
&#13;
  If the disclaimer of warranty and limitation of liability provided&#13;
above cannot be given local legal effect according to their terms,&#13;
reviewing courts shall apply local law that most closely approximates&#13;
an absolute waiver of all civil liability in connection with the&#13;
Program, unless a warranty or assumption of liability accompanies a&#13;
copy of the Program in return for a fee.&#13;
&#13;
                     END OF TERMS AND CONDITIONS&#13;
&#13;
            How to Apply These Terms to Your New Programs&#13;
&#13;
  If you develop a new program, and you want it to be of the greatest&#13;
possible use to the public, the best way to achieve this is to make it&#13;
free software which everyone can redistribute and change under these terms.&#13;
&#13;
  To do so, attach the following notices to the program.  It is safest&#13;
to attach them to the start of each source file to most effectively&#13;
state the exclusion of warranty; and each file should have at least&#13;
the "copyright" line and a pointer to where the full notice is found.&#13;
&#13;
    &lt;one line to give the program's name and a brief idea of what it does.&gt;&#13;
    Copyright (C) &lt;year&gt;  &lt;name of author&gt;&#13;
&#13;
    This program is free software: you can redistribute it and/or modify&#13;
    it under the terms of the GNU General Public License as published by&#13;
    the Free Software Foundation, either version 3 of the License, or&#13;
    (at your option) any later version.&#13;
&#13;
    This program is distributed in the hope that it will be useful,&#13;
    but WITHOUT ANY WARRANTY; without even the implied warranty of&#13;
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the&#13;
    GNU General Public License for more details.&#13;
&#13;
    You should have received a copy of the GNU General Public License&#13;
    along with this program.  If not, see &lt;http://www.gnu.org/licenses/&gt;.&#13;
&#13;
Also add information on how to contact you by electronic and paper mail.&#13;
&#13;
  If the program does terminal interaction, make it output a short&#13;
notice like this when it starts in an interactive mode:&#13;
&#13;
    &lt;program&gt;  Copyright (C) &lt;year&gt;  &lt;name of author&gt;&#13;
    This program comes with ABSOLUTELY NO WARRANTY; for details type `show w'.&#13;
    This is free software, and you are welcome to redistribute it&#13;
    under certain conditions; type `show c' for details.&#13;
&#13;
The hypothetical commands `show w' and `show c' should show the appropriate&#13;
parts of the General Public License.  Of course, your program's commands&#13;
might be different; for a GUI interface, you would use an "about box".&#13;
&#13;
  You should also get your employer (if you work as a programmer) or school,&#13;
if any, to sign a "copyright disclaimer" for the program, if necessary.&#13;
For more information on this, and how to apply and follow the GNU GPL, see&#13;
&lt;http://www.gnu.org/licenses/&gt;.&#13;
&#13;
  The GNU General Public License does not permit incorporating your program&#13;
into proprietary programs.  If your program is a subroutine library, you&#13;
may consider it more useful to permit linking proprietary applications with&#13;
the library.  If this is what you want to do, use the GNU Lesser General&#13;
Public License instead of this License.  But first, please read&#13;
&lt;http://www.gnu.org/philosophy/why-not-lgpl.html&gt;.&#13;
&#13;
*/&#13;
&#13;
contract CDPCreator is DSMath {&#13;
    WETH9 public weth;&#13;
    ERC20 public peth;&#13;
    ERC20 public dai;&#13;
    SaiTub public tub;&#13;
&#13;
    event CDPCreated(bytes32 id, address creator, uint256 dai);&#13;
&#13;
    constructor(address _weth, address _peth, address _dai, address _tub) public {&#13;
        require(_weth != address(0) &amp;&amp; _peth != address(0) &amp;&amp; _tub != address(0) &amp;&amp; _dai != address(0));&#13;
        weth = WETH9(_weth);&#13;
        peth = ERC20(_peth);&#13;
        dai = ERC20(_dai);&#13;
        tub = SaiTub(_tub);&#13;
&#13;
        weth.approve(address(tub), uint(-1));&#13;
        peth.approve(address(tub), uint(-1));&#13;
    }&#13;
&#13;
    function createCDP(uint256 amountDAI) payable external {&#13;
        require(msg.value &gt;= 0.005 ether);&#13;
        require(address(weth).call.value(msg.value)());&#13;
&#13;
        bytes32 cupID = tub.open();&#13;
        &#13;
        uint256 amountPETH = rdiv(msg.value, tub.per());&#13;
        tub.join(amountPETH);&#13;
        tub.lock(cupID, amountPETH);&#13;
        tub.draw(cupID, amountDAI);&#13;
&#13;
        tub.give(cupID, msg.sender);&#13;
        dai.transfer(msg.sender, amountDAI);&#13;
&#13;
        emit CDPCreated(cupID, msg.sender, amountDAI);&#13;
    }&#13;
&#13;
    function lockETH(uint256 id) payable external {&#13;
        require(address(weth).call.value(msg.value)());&#13;
&#13;
        uint256 amountPETH = rdiv(msg.value, tub.per());&#13;
        tub.join(amountPETH);&#13;
&#13;
        tub.lock(bytes32(id), amountPETH);&#13;
    }&#13;
&#13;
    function convertETHToPETH() payable external {&#13;
        require(address(weth).call.value(msg.value)());&#13;
&#13;
        uint256 amountPETH = rdiv(msg.value, tub.per());&#13;
        tub.join(amountPETH);&#13;
        peth.transfer(msg.sender, amountPETH);&#13;
    }&#13;
&#13;
    function convertPETHToETH(uint256 amountPETH) external {&#13;
        require(peth.transferFrom(msg.sender, address(this), amountPETH));&#13;
        &#13;
        uint256 bid = tub.bid(amountPETH);&#13;
        tub.exit(amountPETH);&#13;
        weth.withdraw(bid);&#13;
        msg.sender.transfer(bid);&#13;
    }&#13;
&#13;
    function () payable external {&#13;
        //only accept payments from WETH withdrawal&#13;
        require(msg.sender == address(weth));&#13;
    }&#13;
}