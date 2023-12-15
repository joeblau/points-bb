// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {PointsBuyAndBurn} from "../src/PointsBuyAndBurn.sol";

contract PointsBuyAndBurnTest is Test {
    PointsBuyAndBurn public pointsBuyAndBurn;

    function setUp() public {
        pointsBuyAndBurn = new PointsBuyAndBurn();
        pointsBuyAndBurn.setNumber(0);
    }

    function testIncrement() public {
        pointsBuyAndBurn.increment();
        assertEq(pointsBuyAndBurn.number(), 1);
    }

    function testSetNumber(uint256 x) public {
        pointsBuyAndBurn.setNumber(x);
        assertEq(pointsBuyAndBurn.number(), x);
    }
}
