// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/shared/access/ConfirmedOwner.sol";

error InsufficientBet();
error NoWinnings();
error ContractPaused();

/**
 * @title SimpleSlotGame Contract
 * @notice A contract that gets random values from Chainlink VRF V2 and uses it to play a slot game
 */
contract SimpleSlotGame is VRFConsumerBaseV2, ConfirmedOwner {
    VRFCoordinatorV2Interface immutable COORDINATOR;
    uint64 immutable s_subscriptionId; 
    bytes32 immutable s_keyHash;

    uint32 public constant DEFAULT_CALLBACK_GAS_LIMIT = 40000;
    uint16 public constant DEFAULT_REQUEST_CONFIRMATIONS = 3;
    uint32 public constant NUM_WORDS = 1;

    uint256 public constant JACKPOT_NUMBER = 777;
    uint256 public s_multiplier = 10;

    mapping(uint256 => address) private s_spinners;
    mapping(address => uint256) public winnings;

    event SpinStarted(uint256 indexed requestId, address indexed spinner);
    event RandomNumberFulfilled(uint256 indexed requestId, uint256 randomNumber, bool isJackpot);
    event WinningsWithdrawn(address indexed player, uint256 amount);

    constructor(
        uint64 subscriptionId,
        address vrfCoordinator,
        bytes32 keyHash
    )
        VRFConsumerBaseV2(vrfCoordinator)
        ConfirmedOwner(msg.sender)
    {
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
        s_keyHash = keyHash;
        s_subscriptionId = subscriptionId;
    }
    
    function spin() public payable whenNotPaused {
        if (msg.value == 0) revert InsufficientBet();
        
        uint256 requestId = COORDINATOR.requestRandomWords(
            s_keyHash, 
            s_subscriptionId,  
            DEFAULT_REQUEST_CONFIRMATIONS,
            DEFAULT_CALLBACK_GAS_LIMIT,
            NUM_WORDS
        );
        
        s_spinners[requestId] = msg.sender;
        emit SpinStarted(requestId, msg.sender);
    }

    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal override { 
        uint256 randomResult = (randomWords[0] % 1000) + 1;
        bool isJackpot = randomResult == JACKPOT_NUMBER;
        address spinner = s_spinners[requestId];

        if (isJackpot) {
            winnings[spinner] += msg.value * s_multiplier;
        }

        emit RandomNumberFulfilled(requestId, randomResult, isJackpot);
    }

    function withdrawWinnings() public whenNotPaused {
        uint256 amount = winnings[msg.sender];
        if (amount == 0) revert NoWinnings();
        winnings[msg.sender] = 0;
        payable(msg.sender).transfer(amount);

        emit WinningsWithdrawn(msg.sender, amount);
    }

    // Security and contract maintenance functions

    function updateMultiplier(uint256 newMultiplier) public onlyOwner {
        s_multiplier = newMultiplier;
    }

    bool public paused = false;

    modifier whenNotPaused() {
        if (paused) revert ContractPaused();
        _;
    }

    function pauseContract() public onlyOwner {
        paused = true;
    }

    function resumeContract() public onlyOwner {
        paused = false;
    }
}