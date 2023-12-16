// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { console } from "forge-std/Console.sol";
import '@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol';
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract PointsBuyAndBurn {
    ISwapRouter public immutable swapRouter;
    IERC20 public immutable points;

    uint40 public immutable genesisTs;
    uint256 public cooldownUnlockTs;

    uint256 public constant BUY_AND_BURN_COOLDOWN_TS = 8 hours;
    uint256 public constant BUY_AND_BURN_AMOUNT = 0.25 ether;

    address public constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address public constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2; 
    address public constant POINTS = 0xd7C1EB0fe4A30d3B2a846C04aa6300888f087A5F; 
    address public constant SWAP_ROUTER = 0xE592427A0AEce92De3Edee1F18E0157C05861564;
    
    event BuyAndBurn(address indexed sender, uint256 pointsBurned);

    constructor() {
        genesisTs = uint40(block.timestamp);
        cooldownUnlockTs = block.timestamp + BUY_AND_BURN_COOLDOWN_TS;
        swapRouter = ISwapRouter(SWAP_ROUTER);
        points = IERC20(POINTS);
    }
    

    function buyAndBurn() public {
        require(cooldownUnlockTs > block.timestamp, "Cooldown not unlocked yet");
        require(address(this).balance >= BUY_AND_BURN_AMOUNT, "Insufficient ETH balance for buy and burn");        

        uint256 amountIn = BUY_AND_BURN_AMOUNT;

        TransferHelper.safeApprove(WETH, SWAP_ROUTER, amountIn);

        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams({
            tokenIn: WETH,
            tokenOut: POINTS,
            fee: 3000,
            recipient:DEAD,
            deadline: block.timestamp + 15 minutes,
            amountIn: amountIn,
            amountOutMinimum: 0,
            sqrtPriceLimitX96: 0
        });

        uint256 pointsOut = swapRouter.exactInputSingle(params);

        cooldownUnlockTs = block.timestamp + BUY_AND_BURN_COOLDOWN_TS;

        emit BuyAndBurn(msg.sender, pointsOut);
    }
}
