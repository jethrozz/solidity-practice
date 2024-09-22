// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;


import "./ERC20.sol";

contract MY_WETH is ERC20{
    error BalanceNotEnough();
    string public testMethod = "";
    event Cunkuan(address indexed dst, uint256 value);
    event Qukuan(address indexed src, uint256 value);
    
    //构造函数，初始化name 和symbol
    constructor() ERC20("MY_WETH", "MY_WETH"){}

    // 回调函数，当用户往WETH合约转ETH时，会触发deposit()函数
    //不是很理解这句话，‘当用户往WETH合约转ETH时’ 
    fallback() external payable {
        testMethod = "fallback";
        cunkuan();
    }
    // 回调函数，当用户往WETH合约转ETH时，会触发deposit()函数
    receive() external payable{
        testMethod = "receive";
        cunkuan();
    }

        // 存款函数，当用户存入ETH时，给他铸造等量的WETH
    function cunkuan() public payable {
        _mint(msg.sender, msg.value);
        emit Cunkuan(msg.sender, msg.value);
    }


    function qukuan(uint amount) public{
        testMethod = "qukuan";
        if(balanceOf(msg.sender)  < amount){
            revert BalanceNotEnough();
        }

        _burn(msg.sender, amount);

        payable(msg.sender).transfer(amount);
        emit Qukuan(msg.sender, amount);
    }

}