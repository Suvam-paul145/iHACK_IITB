// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/vrf/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/shared/access/ConfirmedOwner.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@chainlink/contracts/src/v0.8/automation/AutomationCompatible.sol";

/**
 * @title Roulette Contract
 * @notice A contract that gets random values from Chainlink VRF V2 and uses it to play roulette
 */

contract Roulette is
    VRFConsumerBaseV2,
    ConfirmedOwner,
    AutomationCompatibleInterface
{
    VRFCoordinatorV2Interface immutable COORDINATOR;
    IERC20 public linkToken;

    uint64 immutable s_subscriptionId;
    bytes32 immutable s_keyHash;
    uint32 public callbackGasLimit = 2500000;
    uint16 public requestConfirmations = 3;
    uint32 public numWords = 1;
    address private newRoller;

    mapping(uint256 => address) private s_rollers;
    mapping(address => uint256) private s_results;
    mapping(address => uint256) public winnings;

    // Mapping from player address to their bets
    // Each player has a fixed-length array representing their bets
    mapping(address => uint256[157]) public playerBets;

    // set up for Chainlink Automation
    bool private invokeUpkeep = false;
    uint256 public rollDiceRequestId;

    // Define arrays for red and black numbers on the roulette wheel
    uint8[] private redNumbers = [
        1,
        3,
        5,
        7,
        9,
        12,
        14,
        16,
        18,
        19,
        21,
        23,
        25,
        27,
        30,
        32,
        34,
        36
    ];
    uint8[] private blackNumbers = [
        2,
        4,
        6,
        8,
        10,
        11,
        13,
        15,
        17,
        20,
        22,
        24,
        26,
        28,
        29,
        31,
        33,
        35
    ];

    // Helper function to check if a number is in an array
    function isInArray(
        uint8[] memory array,
        uint8 number
    ) private pure returns (bool) {
        for (uint i = 0; i < array.length; i++) {
            if (array[i] == number) {
                return true;
            }
        }
        return false;
    }

    event BetPlaced(address indexed player, uint256 totalBetAmount);
    event DiceRolled(uint256 indexed requestId, address indexed roller);
    event RandomNumberFulfilled(
        uint256 indexed requestId,
        uint256 randomResult,
        address indexed roller,
        uint256 totalWinnings
    );
    event WinningsWithdrawn(address indexed player, uint256 amount);

    constructor(
        uint64 subscriptionId,
        address vrfCoordinator,
        bytes32 keyHash,
        address _linkToken
    ) VRFConsumerBaseV2(vrfCoordinator) ConfirmedOwner(msg.sender) {
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
        s_keyHash = keyHash;
        s_subscriptionId = subscriptionId;
        linkToken = IERC20(_linkToken);
    }

    function placeBets(uint256[157] calldata betAmounts) external {
        uint256 totalBetAmount = 0;
        for (uint i = 0; i < betAmounts.length; i++) {
            totalBetAmount += betAmounts[i];
        }

        require(totalBetAmount > 0, "Total bet amount must be greater than 0");

        // Ensure the player has approved the contract to spend their LINK tokens & has accurate amount
        require(
            linkToken.allowance(msg.sender, address(this)) >= totalBetAmount,
            "Contract is not allowed to spend enough LINK tokens."
        );
        require(
            linkToken.allowance(msg.sender, address(this)) >= totalBetAmount,
            "Insufficient LINK balance"
        );

        // Transfer LINK Tokens from the player to the contract
        require(
            linkToken.transferFrom(msg.sender, address(this), totalBetAmount),
            "Failed to transfer LINK tokens"
        );

        playerBets[msg.sender] = betAmounts;

        // Store the address of the user who placed the bet
        newRoller = msg.sender;

        emit BetPlaced(newRoller, totalBetAmount);

        // After placing bets, mark that upkeep is needed for Chainlink Automation
        invokeUpkeep = true;
    }

    function rollDice(address newroller) public returns (uint256 requestId) {
        require(playerBets[newroller].length > 0, "No bet placed");

        requestId = COORDINATOR.requestRandomWords(
            s_keyHash,
            s_subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );

        s_rollers[requestId] = newroller;

        emit DiceRolled(requestId, newroller);

        // After rolling dice, mark that no further upkeep is needed until the next bets are placed
        invokeUpkeep = false;

        rollDiceRequestId = requestId;
    }

    // Set result to be between 1 and 36 for roulette
    function fulfillRandomWords(
        uint256 requestId,
        uint256[] memory randomWords
    ) internal override {
        uint256 randomResult = (randomWords[0] % 36) + 1;
        address roller = s_rollers[requestId];
        uint256[157] storage betsArray = playerBets[roller];
        uint256 totalWinnings = 0;

        // check for straight bets and return a 35:1 payout
        if (betsArray[randomResult] > 0) {
            totalWinnings +=
                (betsArray[randomResult] * 35) +
                betsArray[randomResult];
        }

        // check for split bets and payout is 17:1
        for (uint256 i = 37; i <= 96; i++) {
            if (betsArray[i] > 0) {
                // Retrieve the two numbers associated with this split bet index
                (uint256 number1, uint256 number2) = getSplitBetNumbers(i);

                // Check if the random result matches either of the two numbers
                if (randomResult == number1 || randomResult == number2) {
                    totalWinnings += (betsArray[i] * 17) + betsArray[i];
                    // A number can only be part of one winning split bet
                    break;
                }
            }
        }

        // check for street bets and payout is 11:1
        if (randomResult != 0) {
            for (uint256 i = 0; i < 14; i++) {
                uint256 betIndex = 97 + i;
                uint256 lowerBound = 1 + (i * 3);
                uint256 upperBound = lowerBound + 2;

                if (
                    randomResult >= lowerBound &&
                    randomResult <= upperBound &&
                    betsArray[betIndex] > 0
                ) {
                    totalWinnings +=
                        (betsArray[betIndex] * 11) +
                        betsArray[betIndex];
                    break; // Only one six-line bet can win, so we can break the loop
                }
            }
        }

        // check for corner bets and payout is 8:1
        for (uint256 i = 0; i < 23; i++) {
            uint256 betIndex = 111 + i;

            // define numbers covered by the corner bet
            uint256 num1 = (i / 4) * 3 + (i % 4) + 1;
            uint256 num2 = num1 + 1;
            uint256 num3 = num1 + 3;
            uint256 num4 = num3 + 1;

            // special case for the 1st corner bet
            if (i == 0) {
                num1 = 0;
                num3 = 1;
                num4 = 2;
            }

            // check if the random result is oen of the corner numbers
            if (
                (randomResult == num1 ||
                    randomResult == num2 ||
                    randomResult == num3 ||
                    randomResult == num4) && betsArray[betIndex] > 0
            ) {
                totalWinnings +=
                    (betsArray[betIndex] * 8) +
                    betsArray[betIndex];
            }
        }

        // check for six-line (double street) bets and payout 5:1
        if (randomResult != 0) {
            // Check each six-line bet
            for (uint256 i = 0; i < 11; i++) {
                uint256 betIndex = 134 + i;
                uint256 lowerBound = 1 + (i * 3);
                uint256 upperBound = lowerBound + 5;

                if (
                    randomResult >= lowerBound &&
                    randomResult <= upperBound &&
                    betsArray[betIndex] > 0
                ) {
                    totalWinnings +=
                        (betsArray[betIndex] * 5) +
                        betsArray[betIndex];
                    break; // Only one six-line bet can win, so we can break the loop
                }
            }
        }

        // check for column bets and return a 2:1 payout
        if (randomResult != 0) {
            // Check 1st column (1, 4, 7, ..., 34)
            if (randomResult % 3 == 1 && betsArray[145] > 0) {
                totalWinnings += (betsArray[145] * 2) + betsArray[145];
            }
            // Check 2nd column (2, 5, 8, ..., 35)
            else if (randomResult % 3 == 2 && betsArray[146] > 0) {
                totalWinnings += (betsArray[146] * 2) + betsArray[146];
            }
            // Check 3rd column (3, 6, 9, ..., 36)
            else if (randomResult % 3 == 0 && betsArray[147] > 0) {
                totalWinnings += (betsArray[147] * 2) + betsArray[147];
            }
        }

        // check for dozens and return a 2:1 payout
        if (randomResult >= 1 && randomResult <= 12 && betsArray[148] > 0) {
            // 1st 12 number rolled, payout 1st 12 bet
            totalWinnings += (betsArray[148] * 2) + betsArray[148];
        } else if (
            randomResult >= 13 && randomResult <= 24 && betsArray[149] > 0
        ) {
            // 2nd 12 number rolled, payout 2nd 12 bet
            totalWinnings += (betsArray[149] * 2) + betsArray[149];
        } else if (
            randomResult >= 25 && randomResult <= 36 && betsArray[150] > 0
        ) {
            // 3rd 12 number rolled, payout 3rd 12 bet
            totalWinnings += (betsArray[150] * 2) + betsArray[150];
        }

        // check for red/black bets and return a 1:1 payout (index 151 and 152)
        if (randomResult != 0) {
            if (
                isInArray(redNumbers, uint8(randomResult)) && betsArray[151] > 0
            ) {
                totalWinnings += betsArray[151] * 2;
            } else if (
                isInArray(blackNumbers, uint8(randomResult)) &&
                betsArray[152] > 0
            ) {
                totalWinnings += betsArray[152] * 2;
            }
        }

        // check for high/low bets and return a 1:1 payout (index 153 adn 154)
        if (randomResult >= 1 && randomResult <= 18 && betsArray[154] > 0) {
            totalWinnings += betsArray[154] * 2;
        } else if (
            randomResult >= 19 && randomResult <= 36 && betsArray[153] > 0
        ) {
            totalWinnings += betsArray[153] * 2;
        }

        // check for even/odd bets and return a 1:1 payout (idex 155 and 156)
        if (randomResult != 0) {
            if (randomResult % 2 == 0 && betsArray[155] > 0) {
                // Even number rolled, payout even bet
                totalWinnings += betsArray[155] * 2;
            } else if (randomResult % 2 != 0 && betsArray[156] > 0) {
                // Odd number rolled, payout odd bet
                totalWinnings += betsArray[156] * 2;
            }
        }

        // Update the winnings for the roller
        winnings[roller] += totalWinnings;

        emit RandomNumberFulfilled(
            requestId,
            randomResult,
            roller,
            totalWinnings
        );

        //Clean up bets after being settled
        delete playerBets[roller];
    }

    // A helper function to get the two numbers associated with a split bet index
    function getSplitBetNumbers(
        uint256 index
    ) private pure returns (uint256, uint256) {
        // Mapping of index to split bet numbers based on the provided mapping

        uint8[2][60] memory splitMap = [
            [0, 1],
            [0, 2],
            [0, 3],
            [1, 4],
            [4, 7],
            [7, 10],
            [10, 13],
            [13, 16],
            [16, 19],
            [19, 22],
            [22, 25],
            [25, 28],
            [28, 31],
            [31, 34],
            [2, 5],
            [5, 8],
            [8, 11],
            [11, 14],
            [14, 17],
            [17, 20],
            [20, 23],
            [23, 26],
            [26, 29],
            [29, 32],
            [32, 35],
            [3, 6],
            [6, 9],
            [9, 12],
            [12, 15],
            [15, 18],
            [18, 21],
            [21, 24],
            [24, 27],
            [27, 30],
            [30, 33],
            [33, 36],
            [1, 2],
            [2, 3],
            [4, 5],
            [5, 6],
            [7, 8],
            [8, 9],
            [10, 11],
            [11, 12],
            [13, 14],
            [14, 15],
            [16, 17],
            [17, 18],
            [19, 20],
            [20, 21],
            [22, 23],
            [23, 24],
            [25, 26],
            [26, 27],
            [28, 29],
            [29, 30],
            [31, 32],
            [32, 33],
            [34, 35],
            [35, 36]
        ];

        if ((index >= 37) && (index <= 96)) {
            uint256 pairIndex = index - 37;
            return (splitMap[pairIndex][0], splitMap[pairIndex][1]);
        }

        // This is a placeholder return statement
        return (0, 0);
    }

    // This function is called by the Chainlink Keeper network to check if any upkeep is needed
    function checkUpkeep(
        bytes calldata
    ) external view override returns (bool upkeepNeeded, bytes memory) {
        upkeepNeeded = invokeUpkeep;
        return (upkeepNeeded, "0x0");
    }

    // This function is called by the Chainlink Keeper network to perform any necessary upkeep
    function performUpkeep(bytes calldata) external override {
        (bool upkeepNeeded, ) = this.checkUpkeep("");
        if (upkeepNeeded) {
            rollDice(newRoller);
        }
    }

    // Function to get the current winnings of a user
    function getCurrentWinnings(address user) public view returns (uint256) {
        return winnings[user];
    }

    function withdrawWinnings() public {
        uint256 amount = winnings[msg.sender];
        require(amount > 0, "No winnings to withdraw");
        winnings[msg.sender] = 0;

        // Use LINK token's transfer function to send winnings
        require(
            linkToken.transfer(msg.sender, amount),
            "Failed to transfer winnings"
        );

        emit WinningsWithdrawn(msg.sender, amount);
    }
}
