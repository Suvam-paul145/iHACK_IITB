import { Signer } from "ethers";
import * as ethers from "ethers";

export type Receipt = {
  from: string;
  to: string;
  tokenSymbol: string;
  amount: string;
  chainFrom: number;
  chainTo: number;
  nonce: string;
};

export const parseReceipt = (receipt: any): Receipt => {
  return {
    from: String(receipt.from).toLowerCase(),
    to: String(receipt.to).toLowerCase(),
    tokenSymbol: receipt.tokenSymbol,
    amount: receipt.amount.toString(),
    chainFrom: receipt.chainFrom.toString(),
    chainTo: receipt.chainTo.toString(),
    nonce: receipt.nonce.toString(),
  };
};

export const signReceipt = async (
  receipt: Receipt,
  signer: Signer
): Promise<string> => {
  console.log(receipt.from);
  const message = ethers.utils.solidityPack(
    ["bytes", "bytes", "string", "uint256", "uint256", "uint256", "uint256"],
    [
      receipt.from,
      receipt.to,
      receipt.tokenSymbol,
      receipt.amount,
      receipt.chainFrom,
      receipt.chainTo,
      receipt.nonce,
    ]
  );

  const hash = ethers.utils.keccak256(ethers.utils.arrayify(message));

  return signer.signMessage(ethers.utils.arrayify(hash));
};
