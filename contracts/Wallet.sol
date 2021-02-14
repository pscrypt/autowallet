// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "openzeppelin-solidity/contracts/access/Ownable.sol";
import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";

contract Wallet is Ownable {
    address public eoa;
    address public router;
    uint256 public gasPriceThreshold;
    address public receivingToken;
    uint256 public minSwapAmount;
    bool public automationEnabled = true;

    event NewWithdraw(
        address wallet,
        address withdrawer,
        address token,
        uint256 amount
    );
    event SwitchAutomation(address wallet);
    event EoaChanged(address wallet, address eoa);
    event ReceivingTokenChanged(address wallet, address token);

    constructor(
        address _eoa,
        address _owner,
        uint256 _gasPriceThreshold,
        address _receivingToken,
        uint256 _minSwapAmount,
        address _factory
    ) {
        eoa = _eoa;
        gasPriceThreshold = _gasPriceThreshold;
        receivingToken = _receivingToken;
        minSwapAmount = _minSwapAmount;
        router = _factory;

        transferOwnership(_owner);
    }

    function withdraw(address _token, uint256 _amount) external returns (bool) {
        require(
            owner() == msg.sender || router == msg.sender,
            "Sender must be owner or router"
        );

        bool result = IERC20(_token).transfer(router, _amount);

        emit NewWithdraw(address(this), msg.sender, _token, _amount);

        return result;
    }

    function changeEoa(address _address) external onlyOwner {
        eoa = _address;
        emit EoaChanged(address(this), _address);
    }

    function changeReceivingToken(address _token) external onlyOwner {
        receivingToken = _token;
        emit ReceivingTokenChanged(address(this), _token);
    }

    function switchAutomation() external onlyOwner {
        automationEnabled = !automationEnabled;
        emit SwitchAutomation(address(this));
    }

    fallback() external payable {}
}
