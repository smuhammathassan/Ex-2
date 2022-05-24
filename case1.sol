//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.4;

contract Case1 {
    address public admin;
    uint256 deadline;
    address public heirSetter;

    mapping(address => uint256) public addressToAmountFunded;

    constructor(address _heirSetter) {
        admin = msg.sender;
        deadline = block.timestamp + 1 minutes;
        heirSetter = _heirSetter;
    }

    modifier onlyOwner() {
        require(msg.sender == admin, "You are not the Admin");
        _;
    }

    modifier deadlinePassed() {
        require(deadline <= block.timestamp, "deadline not passed");
        _;
    }

    function designateHeir(address _newAdmin) public deadlinePassed {
        require(msg.sender == heirSetter, "You are not Heir Setter");
        deadline = block.timestamp + 1 minutes;
        admin = _newAdmin;
    }

    function fund() public payable {
        addressToAmountFunded[msg.sender] += msg.value;
    }

    function withdraw(uint256 _amountInWei) public payable onlyOwner {
        //uint256 amountInWei = _amount * 10**18;
        if (_amountInWei == 0) {
            deadline = block.timestamp + 1 minutes;
        } else {
            require(
                address(this).balance >= _amountInWei,
                "Not enough balance!"
            );
            deadline = block.timestamp + 1 minutes;
            payable(msg.sender).transfer(_amountInWei);
        }
    }

    function checkBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
