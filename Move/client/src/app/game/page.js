"use client";

import HeaderText from "@/components/HeaderText";
import Navbar from "@/components/Navbar";
import GameCarousel from "@/components/GameCarousel";
import MostPlayed from "@/components/MostPlayed";
import {
  useWallet,
  InputTransactionData,
} from "@aptos-labs/wallet-adapter-react";
import LetsPlaySection from "@/components/LetsPlaySection";
import axios from "axios";
// const CLIENT_ID ="Ooa368г8SY5gUNIg4x6";
const baseUrl = 'YOUR_BASE_URL'; // Replace with your base URL
const clientApiKey = 'YOUR_CLIENT_API_KEY';
const authToken = 'AUTH_TOKEN';

export default function Page() {
  const { account, signAndSubmitTransaction } = useWallet();
  const getPortfolio = async () => {
  try {
    const response = await axios.get(`${baseUrl}/api/v1/portfolio`, {
      headers: {
        'x-api-key': clientApiKey,
        'Authorization': `Bearer ${authToken}`,
        'accept': 'application/json',
      }
    });

    console.log(response.data); // Handle the response data here
    return response.data;
  } catch (error) {
    console.error('Request failed:', error);
    throw error; // Handle the error here
  }
};
  return (
    <>
      <Navbar />
      <div className="pt-32 bg-sharp-black text-white px-14">
        <HeaderText
          header="Games"
          description="Hey champ! hit the bank and get your asserts to play a game."
        />
        <GameCarousel />
        <MostPlayed />
        <LetsPlaySection />
      </div>
    </>
  );
}
