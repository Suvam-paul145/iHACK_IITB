import {Aptos, AptosConfig, Network} from "@aptos-labs/ts-sdk";

const config = new AptosConfig({ network: Network.DEVNET });

export const getAptosClient = () => new Aptos(config);