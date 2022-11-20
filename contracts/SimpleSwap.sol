// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { ISimpleSwap } from "./interface/ISimpleSwap.sol";
import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "hardhat/console.sol";

contract SimpleSwap is ISimpleSwap, ERC20("lpToken", "LP") {
    ERC20 public tokenA;
    ERC20 public tokenB;
    uint private reserveA;
    uint private reserveB;
    constructor(address token0, address token1) {
        require(token0 != address(0), "SimpleSwap: TOKENA_IS_NOT_CONTRACT");
        require(token1 != address(0), "SimpleSwap: TOKENB_IS_NOT_CONTRACT");
        require(token0 != token1, "SimpleSwap: TOKENA_TOKENB_IDENTICAL_ADDRESS");

        address addressTokenA = uint160(token0) < uint160(token1) ? token0 : token1;
        address addressTokenB = uint160(token0) < uint160(token1) ? token1 : token0;
        tokenA = ERC20(addressTokenA);
        tokenB = ERC20(addressTokenB);
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
    ) external override returns (uint256){
        require(tokenIn == address(tokenA) || tokenIn == address(tokenB), "SimpleSwap: INVALID_TOKEN_IN");
        require(tokenOut == address(tokenA) || tokenOut == address(tokenB), "SimpleSwap: INVALID_TOKEN_OUT");
        require(tokenIn != tokenOut, "SimpleSwap: IDENTICAL_ADDRESS");
        require(amountIn != 0, "SimpleSwap: INSUFFICIENT_INPUT_AMOUNT");

        uint actualAmountIn = transferInAmount(ERC20(tokenIn), msg.sender, amountIn);
        uint amountOut = tokenIn == address(tokenA) ? 
                         reserveB - reserveA * reserveB / (reserveA + actualAmountIn)
                       : reserveA - reserveA * reserveB / (reserveB + actualAmountIn);
        require(amountOut != 0, "SimpleSwap: INSUFFICIENT_OUTPUT_AMOUNT");

        bool success = ERC20(tokenOut).transfer(msg.sender, amountOut);
        require(success, "ERC20 transfer out fail");

        if (tokenIn == address(tokenA)) {
            reserveA += actualAmountIn;
            reserveB -= amountOut;
        } else {
            reserveB += actualAmountIn;
            reserveA -= amountOut;
        }
        
        emit Swap(msg.sender, tokenIn, tokenOut, actualAmountIn, amountOut);

        return amountOut;
    }

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
            uint256,
            uint256,
            uint256
        ){
            require(amountAIn != 0 && amountBIn != 0, "SimpleSwap: INSUFFICIENT_INPUT_AMOUNT");
            // transfer tokenA & token B
            
            uint actualAmountA;
            uint actualAmountB;

            if (totalSupply() == 0) {
                actualAmountA = amountAIn;
                actualAmountB = amountBIn;
            } else {
                // mul before div
                actualAmountA = Math.min(amountAIn, amountBIn * reserveA / reserveB);
                actualAmountB = Math.min(amountBIn, amountAIn * reserveB / reserveA);
            }

            uint finalAmountA = transferInAmount(tokenA, msg.sender, actualAmountA);
            uint finalAmountB = transferInAmount(tokenB, msg.sender, actualAmountB);
            uint liquidity = Math.sqrt(finalAmountA * finalAmountB);

            _mint(msg.sender, liquidity);
            reserveA += finalAmountA;
            reserveB += finalAmountB;

            emit AddLiquidity(msg.sender, finalAmountA, finalAmountB, liquidity);
            
            return (finalAmountA, finalAmountB, liquidity);
        }

    /// @notice Remove liquidity from the pool
    /// @param liquidity The amount of liquidity to remove
    /// @return amountA The amount of tokenA received
    /// @return amountB The amount of tokenB received
    function removeLiquidity(uint256 liquidity) external override returns (uint256, uint256){
        require(liquidity != 0, "SimpleSwap: INSUFFICIENT_LIQUIDITY_BURNED");

        uint amountA = liquidity * reserveA / totalSupply();
        uint amountB = liquidity * reserveB / totalSupply();

        reserveA -= amountA;
        reserveB -= amountB;
        
        _transfer(msg.sender, address(this), liquidity);
        _burn(address(this), liquidity);
        tokenA.transfer(msg.sender, amountA);
        tokenB.transfer(msg.sender, amountB);

        emit RemoveLiquidity(msg.sender, amountA, amountB, liquidity);

        return (amountA, amountB);
    }

    /// @notice Get the reserves of the pool
    /// @return reserveA The reserve of tokenA
    /// @return reserveB The reserve of tokenB
    function getReserves() external override view returns (uint256, uint256){
        return (reserveA, reserveB);
    }

    /// @notice Get the address of tokenA
    /// @return tokenAddress The address of tokenA
    function getTokenA() external override view returns (address tokenAddress){
        return address(tokenA);
    }

    /// @notice Get the address of tokenB
    /// @return tokenAddress The address of tokenB
    function getTokenB() external override view returns (address tokenAddress){
        return address(tokenB);
    }

    function transferInAmount(ERC20 token, address from, uint256 amount) internal returns (uint actualAmount) {
        uint balance = token.balanceOf(address(this));
        bool success = token.transferFrom(from, address(this), amount);
        require(success, "ERC20 transfer fail");
        uint newBalance = token.balanceOf(address(this));
        return newBalance - balance;
    }
}
