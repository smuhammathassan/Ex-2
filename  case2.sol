//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.4;

contract Case2 {
    address public admin;
    uint256 deadline;
    address public heirSetter;
    address[3] public heirs;

    mapping(address => uint256) public addressToAmountFunded;

    constructor(
        address _heirSetter,
        address _heir1,
        address _heir2,
        address _heir3
    ) {
        admin = msg.sender;
        deadline = block.timestamp + 1 minutes;
        heirSetter = _heirSetter;
        heirs = [_heir1, _heir2, _heir3];
    }

    modifier onlyOwner() {
        require(msg.sender == admin, "You are not the Admin");
        _;
    }

    modifier deadlinePassed() {
        require(deadline <= block.timestamp, "deadline not passed");
        _;
    }

    function designateHeir(address _newOwner) public deadlinePassed {
        require(msg.sender == heirSetter, "You are not Heir Setter");
        bool _newOwnerIsInHeirs;
        address[3] memory _heirs = heirs;
        for (uint256 i = 0; i < _heirs.length; i++) {
            if (_heirs[i] == _newOwner) {
                deadline = block.timestamp + 1 minutes;
                admin = _newOwner;
                _newOwnerIsInHeirs = true;
            }
        }
        require(_newOwnerIsInHeirs, "You must select new owner from heirs");
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
