// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { ISimpleSwap } from "./interface/ISimpleSwap.sol";
import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "hardhat/console.sol";

contract SimpleSwap is ISimpleSwap, ERC20("lpToken", "LP") {
    address public tokenA;
    address public tokenB;
    uint private reserveA;
    uint private reserveB;
    constructor(address token0, address token1) {
        require(token0 != address(0), "SimpleSwap: TOKENA_IS_NOT_CONTRACT");
        require(token1 != address(0), "SimpleSwap: TOKENB_IS_NOT_CONTRACT");
        require(token0 != token1, "SimpleSwap: TOKENA_TOKENB_IDENTICAL_ADDRESS");

        tokenA = uint160(token0) < uint160(token1) ? token0 : token1;
        tokenB = uint160(token0) < uint160(token1) ? token1 : token0;
    }
    /// @notice Swap tokenIn for tokenOut with amountIn
    /// @param tokenIn The address of the token to swap from
    /// @param tokenOut The address of the token to swap to
    /// @param amountIn The amount of tokenIn to swap
    /// @return amountOut The amount of tokenOut received
    function swap(
        address tokenIn,
        address tokenOut,
        uint256 amountIn
    ) external override returns (uint256 amountOut){}

    /// @notice Add liquidity to the pool
    /// @param amountAIn The amount of tokenA to add
    /// @param amountBIn The amount of tokenB to add
    /// @return amountA The actually amount of tokenA added
    /// @return amountB The actually amount of tokenB added
    /// @return liquidity The amount of liquidity minted
    function addLiquidity(uint256 amountAIn, uint256 amountBIn)
        external
        override
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        ){
            require(amountA != 0 && amountB != 0, "SimpleSwap: INSUFFICIENT_INPUT_AMOUNT");
        }

    /// @notice Remove liquidity from the pool
    /// @param liquidity The amount of liquidity to remove
    /// @return amountA The amount of tokenA received
    /// @return amountB The amount of tokenB received
    function removeLiquidity(uint256 liquidity) external override returns (uint256 amountA, uint256 amountB){}

    /// @notice Get the reserves of the pool
    /// @return reserveA The reserve of tokenA
    /// @return reserveB The reserve of tokenB
    function getReserves() external override view returns (uint256 reserveA, uint256 reserveB){
        return (reserveA, reserveB);
    }

    /// @notice Get the address of tokenA
    /// @return tokenAddress The address of tokenA
    function getTokenA() external override view returns (address tokenAddress){
        return tokenA;
    }

    /// @notice Get the address of tokenB
    /// @return tokenAddress The address of tokenB
    function getTokenB() external override view returns (address tokenAddress){
        return tokenB;
    }
}
