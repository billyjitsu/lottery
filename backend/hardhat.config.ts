import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@nomicfoundation/hardhat-foundry";
require("dotenv").config();

const config: HardhatUserConfig = {
  solidity: {
    compilers: [
      {
        version: "0.8.9",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
      // {
      //   version: "0.8.13",
      //   settings: {
      //     optimizer: {
      //       enabled: true,
      //       runs: 200,
      //     },
      //   },
      // },
    ],
  },

  networks: {
    hardhat: {
      chainId: 1337,
    },

    // goerli: {
    //   url: `${process.env.GOERLI_RPC_URL}`,
    //   accounts: [`${process.env.PRIVATE_KEY}`],
    //   gas: 300000000,
    //   gasPrice: 100000000000,
    // },
    // polygon: {
    //   url: process.env.POLYGON_RPC_URL,
    //   accounts: [`${process.env.PRIVATE_KEY}`],
    // },
    mumbai: {
      url: `${process.env.MUMBAI_RPC_URL}`,
      accounts: [`${process.env.PRIVATE_KEY}`],
      gas: 200000000,
      gasPrice: 100000000000,
    },
    mantletestnet: {
      url: "https://rpc.testnet.mantle.xyz/",
      accounts: [`${process.env.PRIVATE_KEY}`],
    },
    zkEVMTestnet: {
      url: `https://rpc.public.zkevm-test.net`,
      accounts: [`${process.env.PRIVATE_KEY}`],
    },
    lineaTestnet: {
      url: `https://linea-goerli.infura.io/v3/${process.env.INFURA_API_KEY}`,
      accounts: [`${process.env.PRIVATE_KEY}`],
    }
  },
  etherscan: {
    // Your API key for Etherscan
    // Obtain one at https://etherscan.io/

    apiKey: {
      polygon: process.env.POLYGON_ETHERSCAN_API_KEY || "",
      polygonMumbai: process.env.POLYGON_ETHERSCAN_API_KEY || "",
      goerli: process.env.ETHERSCAN_API_KEY || "",
      polygonZKEVMTestnet: process.env.POLYGON_ETHERSCAN_API_KEY || "",
      lineaTestnet: process.env.LINEA_API_KEY || "",
    },

    customChains: [
      {
        network: "zkEVMTestnet",
        chainId: 1442,
        urls: {
          apiURL: "https://api-testnet-zkevm.polygonscan.com/api",
          browserURL: "https://testnet-zkevm.polygonscan.com/",
        }, 
      },
      {
        network: "lineaTestnet",
        chainId: 59140,
        urls: {
          apiURL: "https://api.lineascan.build/api",
          browserURL: "https://goerli.lineascan.build/",
        }, 
      },
    ],
  },
};

export default config;
