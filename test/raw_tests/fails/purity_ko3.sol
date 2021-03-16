pragma solidity >=0.6.0;
// SPDX-License-Identifier: UNLICENSED

contract C {
    int x;
    function f () public pure {x = 2;}
}

/* Error : Function declared as pure, but this expression (potentially)
   modifies the state and thus require non-payable (the default) or
   payable. */