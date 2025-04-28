import fs from "fs-extra";
import { task } from "hardhat/config";
import type { TaskArguments } from "hardhat/types";

task("deploy:RewardDistribution").setAction(async function (_taskArguments: TaskArguments, { ethers }) {
  const signers = await ethers.getSigners();
  const factory = await ethers.getContractFactory("RewardDistribution");
  const args = getContractArgs();
  const contract = await factory.connect(signers[0]).deploy(args.rewardTreasury, args.token);
  await contract.waitForDeployment();
  console.log("RewardDistribution deployed to: ", await contract.getAddress());
});

function getContractArgs() {
  const json = fs.readJSONSync("./deployargs/deployRewardDistributionArgs.json");

  const rewardTreasury = String(json.rewardTreasury);
  const token = String(json.token);

  return { rewardTreasury, token };
}
