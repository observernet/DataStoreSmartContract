// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import './libraries/Context.sol';
import "./interfaces/IERC20.sol";

contract DataStore is Context
{
    address private constant OBSR_CONTRACT = address(0x3cB6Be2Fc6677A63cB52B07AED523F93f5a06Cb4);         // Cypress
    //address private constant OBSR_CONTRACT = address(0xDe38B8287FB2556bE19767E8a6dD9Bd20cC15f75);         // Baobab
    IERC20 private _obsr_token;

    address private _admin_account;
    address private _price_account;
    address private _fee_account;

    struct PaymentInfo
    {
        string          name;
        uint256         price;
        uint256         fee;
    }
    mapping(address => PaymentInfo[]) private _paymentList;


    event Payment(address indexed from, string name, uint256 price, uint256 fee);

	constructor()
	{
        _obsr_token = IERC20(OBSR_CONTRACT);
        _admin_account = _msgSender();
    }



    // 결제 내역을 가져온다
    function getPaymentList(address account_) public view returns (PaymentInfo[] memory)
    {
        return (_paymentList[account_]);
    }

    // 결제를 진행한다
    function payment(string memory name_, uint256 price_, uint256 fee_) public
    {
        uint256 balance = _obsr_token.balanceOf(_msgSender());
        uint256 allowance = _obsr_token.allowance(_msgSender(), address(this));

        require(balance >= price_ + fee_, "Insufficient balance");
        require(allowance >= price_ + fee_, "Insufficient allowance");

        _obsr_token.transferFrom(_msgSender(), _price_account, price_);
        _obsr_token.transferFrom(_msgSender(), _fee_account, fee_);

        _paymentList[_msgSender()].push(PaymentInfo(name_, price_, fee_));
        emit Payment(_msgSender(), name_, price_, fee_);
    }



    // 입금 받을 주소 및 수수료 주소를 조회한다
    function getPriceFeeAccount() public view returns (address, address) { return (_price_account, _fee_account); }

    // 입금 받을 주소를 세팅한다
    function setPriceAccount(address account_) public
    {
        require(_admin_account == _msgSender(), "Not Allow Address");
        _price_account = account_;
    }

    // 수수료 주소를 세팅한다
    function setFeeAccount(address account_) public
    {
        require(_admin_account == _msgSender(), "Not Allow Address");
        _fee_account = account_;
    }



    // 관리자 주소를 조회한다
    function getAdminAccount() public view returns (address) { return (_admin_account); }

    // 관리자 주소를 세팅한다
    function setAdminAccount() public
    {
        require(_admin_account == _msgSender(), "Not Allow Address");
        _admin_account = _msgSender();
    }
}
