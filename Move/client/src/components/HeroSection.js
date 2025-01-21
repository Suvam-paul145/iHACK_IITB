"use client";
import Image from "next/image";
import LaunchGameButton from "./LaunchGameButton";
import { useWallet } from "@aptos-labs/wallet-adapter-react";
import { WalletSelector } from "@aptos-labs/wallet-adapter-ant-design";
export default function HeroSection() {
  const { account } = useWallet();
  return (
    <section
      id="hero"
      className="min-h-screen items-center flex flex-col pt-36 px-36"
    >
      <div className="font-display capitalize flex text-white flex-col text-center items-center gap-4">
        <h1 className="text-5xl">
          Place your best move with <br /> <span className="bg-clip-text text-transparent font-bold bg-gradient-to-r from-red-magic to-blue-magic">
            Move
          </span> {" "} <br />
        
        </h1>
        <span className="bg-clip-text mt-4 font-bold text-8xl text-transparent bg-gradient-to-r from-red-magic to-blue-magic">
            APT-CASINO
          </span>
        <h2 className="text-[#B3B3B3] mt-4 text-2xl">
        Dive into the next generation of gaming with APT-Casino where every move is 

          <br /> powered by ZetaChain and Aptos blockchain technology. Discover new games, connect with friends, and 
unlock endless possibilities.
        </h2>
        <div className="flex gap-8 mt-10">
          <WalletSelector />
          <LaunchGameButton />
        </div>
      </div>
      <Image
        src="/images/HeroImage.png"
        width={863}
        height={487}
        alt="Hero image"
      />
    </section>
  );
}
