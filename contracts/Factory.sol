// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "./Wallet.sol";
import "./interfaces/IWallet.sol";
import "./interfaces/IUniswapV2Router02.sol";
import "./libraries/PercentageMath.sol";
import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";

contract Factory {
    using SafeMath for uint256;
    using PercentageMath for uint256;
    address public offchainExecutor;
    address internal uniswapRouterAddress;
    IUniswapV2Router02 internal uniswapRouter;
    // 0.01% = 0.01 * 1e4(PERCENTAGE_FACTOR)
    uint256 public FEE_PERCENT = 100;

    constructor(address _offchainExecutor, address _uniswapRouterAddr) {
        offchainExecutor = _offchainExecutor;
        uniswapRouterAddress = _uniswapRouterAddr;
        uniswapRouter = IUniswapV2Router02(_uniswapRouterAddr);
    }

    struct WalletToken {
        address wallet;
        uint256 amount;
    }

    mapping(address => WalletToken) public walletToken;

    event WalletCreated(
        address wallet,
        address creator,
        address eoa,
        address receivingToken,
        uint256 minSwapAmount,
        uint256 gasPriceThreshold
    );
    event NewSwap(
        address wallet,
        address tokenIn,
        uint256 amountIn,
        address tokenOut,
        uint256 amountOut
    );

    function createWallet(
        uint256 saltNonce,
        address _eoa,
        uint256 _gasPriceThreshold,
        address _receivingToken,
        uint256 _minSwapAmount
    ) public {
        bytes32 salt = keccak256(abi.encode(msg.sender, saltNonce));

        // TODO: Optimize using create2
        Wallet wallet =
            new Wallet{salt: salt}(
                _eoa,
                msg.sender,
                _gasPriceThreshold,
                _receivingToken,
                _minSwapAmount,
                address(this)
            );

        emit WalletCreated(
            address(wallet),
            msg.sender,
            _eoa,
            _receivingToken,
            _minSwapAmount,
            _gasPriceThreshold
        );
    }

    function fetchTokenAndSwap(
        address _wallet,
        address _token,
        uint256 _amount
    ) public returns (bool) {
        require(
            msg.sender == offchainExecutor,
            "RouterFactory: Incorrect executor"
        );
        require(
            IWallet(_wallet).withdraw(_token, _amount),
            "RouterFactory: Withdraw from user wallet failed !!"
        );

        uint256 startGas = gasleft();

        walletToken[_wallet] = WalletToken(_wallet, _amount);
        address _receivingToken = IWallet(_wallet).receivingToken();

        address[] memory _tokens = new address[](2);
        _tokens[0] = _token;
        _tokens[1] = _receivingToken;

        uint256[] memory _reserveAmounts =
            uniswapRouter.getAmountsOut(_amount, _tokens);

        uint256 _amountOut =
            uniswapRouter.getAmountOut(
                _amount,
                _reserveAmounts[0],
                _reserveAmounts[1]
            );

        IERC20(_token).approve(uniswapRouterAddress, _amount);

        // Swap Tokens
        uint256[] memory returnAmount =
            uniswapRouter.swapExactTokensForTokens(
                _amount,
                _amountOut.mul(90).div(100),
                _tokens,
                address(this),
                block.timestamp.add(1800)
            );

        uint256 gasUsed = startGas.sub(gasleft());
        uint256 gasPrice = tx.gasprice;
        uint256 txFee = gasUsed.mul(gasPrice);

        IERC20(_receivingToken).transfer(
            IWallet(_wallet).eoa(),
            returnAmount[0].percentMul(
                PercentageMath.PERCENTAGE_FACTOR.sub(FEE_PERCENT)
            )
        );

        emit NewSwap(
            _wallet,
            _token,
            _amount,
            _receivingToken,
            returnAmount[0]
        );

        return true;
    }
}
