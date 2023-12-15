// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract PointsBuyAndBurn {
    ISwapRouter public immutable swapRouter;
    IERC20 public immutable points;

    uint40 public immutable genesisTs;
    uint256 public cooldownUnlockTs;

    uint256 internal constant BUY_AND_BURN_COOLDOWN_TS = 8 hours;
    uint256 internal constant BUY_AND_BURN_AMOUNT = 0.3 ether;

    address constant POINTS_ADDRESS = 0xd7C1EB0fe4A30d3B2a846C04aa6300888f087A5F; 
    address constant WETH_ADDRESS = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address constant SWAP_ROUTER_ADDRESS = 0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45;
    
    event BuyAndBurn(address indexed sender, uint256 pointsBurned);

    constructor() {
        genesisTs = uint40(block.timestamp);
        cooldownUnlockTs = block.timestamp + BUY_AND_BURN_COOLDOWN_TS;

        swapRouter = ISwapRouter(SWAP_ROUTER_ADDRESS);
        points = IERC20(POINTS_ADDRESS);
    }
    
    function buyAndBurn() external payable {
        require(cooldownUnlockTs > block.timestamp, "Cooldown not unlocked yet");
        require(address(this).balance >= BUY_AND_BURN_AMOUNT, "Insufficient ETH balance for buy and burn");

        // Path: ETH -> POINTS
        address[] memory path = new address[](2);
        path[0] = WETH_ADDRESS;
        path[1] = POINTS_ADDRESS;

        // Parameters for the swap
        ISwapRouter.ExactInputSingleParams memory params =
            ISwapRouter.ExactInputSingleParams({
                tokenIn: path[0],
                tokenOut: path[1],
                fee: 3000,
                recipient: msg.sender,
                deadline: block.timestamp + 15 minutes,
                amountIn: BUY_AND_BURN_AMOUNT,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });

        // Executes the swap
        swapRouter.exactInputSingle{value: msg.value}(params);

        uint256 POINTS_BALANCE = points.balanceOf(address(this));
        points.transfer(address(0), POINTS_BALANCE);

        cooldownUnlockTs = block.timestamp + BUY_AND_BURN_COOLDOWN_TS;
        emit BuyAndBurn(msg.sender, POINTS_BALANCE);
    }

}
