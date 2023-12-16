// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Test, console2 } from "forge-std/Test.sol";
import { PointsBuyAndBurn } from "../src/PointsBuyAndBurn.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract PointsBuyAndBurnTest is Test {
    address POINTS = 0xd7C1EB0fe4A30d3B2a846C04aa6300888f087A5F;
    address WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    PointsBuyAndBurn internal pointsBuyAndBurn;

    function setUp() public {
        vm.createSelectFork("https://eth.llamarpc.com", 18_794_799);
        pointsBuyAndBurn = new PointsBuyAndBurn();
        deal(WETH, address(pointsBuyAndBurn), 239 ether);
        vm.deal(address(pointsBuyAndBurn), 239 ether);
    }

    function testBuyAndBurn() public {
        uint256 initDeadPointsAddress = IERC20(POINTS).balanceOf(pointsBuyAndBurn.DEAD());
        
        pointsBuyAndBurn.buyAndBurn();
        
        uint256 finalDeadPointsAddress = IERC20(POINTS).balanceOf(pointsBuyAndBurn.DEAD());

        assertGe(finalDeadPointsAddress, initDeadPointsAddress, "Points balance should increase");
    }
}
