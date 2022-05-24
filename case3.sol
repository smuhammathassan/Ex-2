//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.4;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

contract Case3 is VRFConsumerBaseV2 {
    VRFCoordinatorV2Interface COORDINATOR;
    uint64 s_subscriptionId;
    address vrfCoordinator = 0x6168499c0cFfCaCD319c818142124B7A15E857ab;
    bytes32 keyHash =
        0xd89b2bf150e3b9e13446986e571fb9cab24b13cea0a43ea20a6049a85cc807cc;
    uint32 callbackGasLimit = 100000;
    uint16 requestConfirmations = 3;
    uint32 numWords = 1;
    uint256[] public s_randomWords;
    uint256 public s_requestId;
    address public owner;
    uint256 deadline;
    address public heirSetter;
    address[3] public heirs;
    bool lock;

    mapping(address => uint256) public addressToAmountFunded;

    constructor(
        uint64 subscriptionId,
        address _heirSetter,
        address _heir1,
        address _heir2,
        address _heir3
    ) VRFConsumerBaseV2(vrfCoordinator) {
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
        s_subscriptionId = subscriptionId;
        owner = msg.sender;
        deadline = block.timestamp + 1 minutes;
        heirSetter = _heirSetter;
        heirs = [_heir1, _heir2, _heir3];
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not the Owner");
        _;
    }

    modifier deadlinePassed() {
        require(deadline <= block.timestamp, "deadline not passed");
        _;
    }

    // modifier isRandomNumberAvailable {
    //     require(s_randomWords[0], "Call the fullfill random words function first and wait for 2 minutues");
    //     _;
    // }

    modifier onlyHeirSetter() {
        require(msg.sender == heirSetter, "You are not Heir Setter");
        _;
    }

    function requestRandomWords() public deadlinePassed onlyHeirSetter {
        require(!lock, "Function is locked to avoid manupulation");
        lock = true;
        s_requestId = COORDINATOR.requestRandomWords(
            keyHash,
            s_subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );
    }

    function fulfillRandomWords(
        uint256, /* requestId */
        uint256[] memory randomWords
    ) internal override {
        s_randomWords = randomWords;
        s_randomWords[0] = (s_randomWords[0] % 3) + 1;
    }

    function designateHeir() public deadlinePassed onlyHeirSetter {
        deadline = block.timestamp + 1 minutes;
        lock = false;
        owner = heirs[s_randomWords[0]];
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
