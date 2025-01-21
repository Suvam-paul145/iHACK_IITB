import {
  MoveVector,
  U64,
  U8,
} from "@aptos-labs/ts-sdk";

const NUM_SLOTS = 36;
const rouletteModule = "roulette";
const aptosinoPackageAddress =
  "0x25e6d86a5a7083d9d61e40381e5238ab6d2e785825eba0183cebb6009483dab4";

const entryFunctionPayload = (func, args, typeArgs) => ({
  function: func,
  typeArguments: typeArgs,
  functionArguments: args,
});
const rouletteEntryFunction = (functionName, args, typeArgs) =>
  entryFunctionPayload(

    `${aptosinoPackageAddress}::${rouletteModule}::${functionName}`,
    args,
    typeArgs
  );

export const spinWheelEntryFunctionPayload = (address,betAmounts, predictedOutcomes) =>
  rouletteEntryFunction("spin_wheel", [address,
    new MoveVector(betAmounts.map((bet) => new U64(Math.round(bet)))),
    new MoveVector(
      predictedOutcomes.map(
        (outcomes) => new MoveVector([new U8(outcomes)])
      )
    ),
  ]);
