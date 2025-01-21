# APT-Casino Smart Contracts

This repository contains the smart contracts used in the APT-Casino platform.

### Roulette Contract

#### Uses Chainlink VRF and Chainlink Automation

The Roulette contract provides functionality for players to place bets, initiate the roulette spin, and receive payouts. The contract maintains a mapping of rollers, tracking who triggered each Chainlink VRF request. Chainlink VRF is integrated into the rollDice function, which requests a random number. The fulfillRandomness function is called automatically with the random result once it's ready. The payout logic is handled in fulfillRandomness. This European Roulette game covers all possible bet types (straight, split, street, corner, six line, column, dozen, red, black, high, low, even, odd), and the payout is calculated based on the respective odds of each win. Chainlink Automation is implemented when a user places a bet. The upKeep is triggered after the bet is placed to automatically roll the dice (spin the roulette wheel), calculate winnings, and withdraw them to the player's wallet.

### Slot Machine Contract

#### Uses Chainlink VRF and Chainlink Automation

The Slot Machine contract is a simple slot game where a user bets a certain amount of ether, and if they hit the jackpot (represented by a specific random number), they win a multiplier of their bet. Future improvements will include different winning combinations, varying rewards, and a house edge.