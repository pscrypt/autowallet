// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

interface IWallet {
    function eoa() external view returns (address);

    function withdraw(address, uint256) external returns (bool);

    function receivingToken() external view returns (address);
}
