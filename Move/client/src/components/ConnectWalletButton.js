"use client";
import { useEffect } from "react";


import { handleClientScriptLoad } from "next/script";
import { TungstenRounded } from "@mui/icons-material";

export default function ConnectWalletButton() {
  

  const onClickHandler = () => {
    // setDefaultTabIndex(1); // Set the default tab index to 1, which corresponds to the Ethereum tab
    setShowAuthFlow(true);
  };

  
  return (
    <div className="bg-gradient-to-r from-red-magic to-blue-magic hover-gradient-shadow rounded-xl p-0.5 cursor-pointer">
      {TungstenRounded ? (
        <div
          className="bg-[#070005] rounded-xl py-3 px-6 h-full flex items-center"
          onClick={onClickHandler}
        >
          Connect wallet
        </div>
      ) : (
        <div
          className="bg-[#070005] rounded-xl py-3 px-6 h-full flex items-center"
          onClick={handleLogout}
        >
          Hello
        </div>
      )}
    </div>
  );
}
