"use client";

import "@/styles/globals.css";
// import Providers from "./providers";
// import { headers } from "next/headers";
import AiModal from "@/components/AiModal";
import { PetraWallet } from "petra-plugin-wallet-adapter";
import { AptosWalletAdapterProvider } from "@aptos-labs/wallet-adapter-react";
import "@aptos-labs/wallet-adapter-ant-design/dist/index.css";
import toast, { Toaster } from 'react-hot-toast';


const metadata = {
  title: "APT-Casino",
  description: "Web3 gaming arena",
};

export default function RootLayout({ children }) {

  const wallets = [new PetraWallet()];
  return (
    <html lang="en">
      <AptosWalletAdapterProvider
        plugins={wallets}
        autoConnect={true}
        onError={(error) => {
          console.log("error", error);
        }}
      >
        <body>
          <AiModal />
          {children}
          <Toaster position="top-right"  />
        </body>
      </AptosWalletAdapterProvider>
    </html>
  );
}
