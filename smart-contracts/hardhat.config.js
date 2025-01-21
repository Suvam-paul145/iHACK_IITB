require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

const { PRIVATE_KEY } = process.env;

module.exports = {
  networks: {
    hardhat: {},
    polygonZkEVM: {
      url: "https://polygonzkevm-testnet.g.alchemy.com/v2/demo", // Replace with actual RPC URL
      accounts: [PRIVATE_KEY],
      chainId: 1422, // Replace with the actual chain ID
    },
    polygonCardanoTestnet: {
      url: "https://rpc.cardona.zkevm-rpc.com", // Replace with actual RPC URL
      accounts: [PRIVATE_KEY],
      chainId: 2442, // Replace with the actual chain ID
    },
    polygonAmoy: {
      url: "https://rpc-amoy.polygon.technology/", // Replace with actual RPC URL
      accounts: [PRIVATE_KEY],
      chainId: 80002, // Replace with the actual chain ID
    },
    snowtrace: {
      url: "https://api.avax-test.network/ext/bc/C/rpc",
      chainId: 43113,
      accounts: [PRIVATE_KEY],
    },
    metis: {
      url: "https://sepolia.metisdevops.link", // Replace with actual RPC URL
      accounts: [PRIVATE_KEY],
      chainId: 59902, // Replace with the actual chain ID
    },
    scroll: {
      url: "https://sepolia-rpc.scroll.io",
      accounts: [PRIVATE_KEY],
      chainId: 534351,
    },
  },
  etherscan: {
    apiKey: {
      polygonAmoy: "713e704f-5a62-4a0f-b30f-9fc9d1001aa2",
      snowtrace: "snowtrace",
    },
    customChains: [
      {
        network: "polygonAmoy",
        chainId: 80002,
        urls: {
          apiURL:
            "https://www.oklink.com/api/explorer/v1/contract/verify/async/api/polygonAmoy",
          browserURL: "https://www.oklink.com/polygonAmoy",
        },
      },
      {
        network: "snowtrace",
        chainId: 43113,
        urls: {
          apiURL:
            "https://api.routescan.io/v2/network/testnet/evm/43113/etherscan",
          browserURL: "https://avalanche.testnet.localhost:8080",
        },
      },
    ],
  },
  solidity: {
    version: "0.8.20",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
};
