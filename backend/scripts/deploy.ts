import { ethers, run } from "hardhat";
import { deriveSponsorWalletAddress } from "@api3/airnode-admin";


async function main() {

  const NetworkAirnode = "0xa0AD79D995DdeeB18a14eAef56A549A04e3Aa1Bd"; // Polygon
  const airnodeRrp = "0x6238772544f029ecaBfDED4300f13A3c4FE84E1D";  //Nodary 0x6238772544f029ecaBfDED4300f13A3c4FE84E1D    ANU: 0x9d3C147cA16DB954873A498e0af5852AB39139f2
  const xpub = "xpub6CuDdF9zdWTRuGybJPuZUGnU4suZowMmgu15bjFZT2o6PUtk4Lo78KGJUGBobz3pPKRaN9sLxzj21CMe6StP3zUsd8tWEJPgZBesYBMY7Wo";
  const sponsor = "";
  const endpoint = "0xfb6d017bb87991b7495f563db3c8cf59ff87b09781947bb1e417006ad7f55a78";

  // The new way of deploying contracts    Name of Contract, Constructor Arguments, Overrides
  const lottery = await ethers.deployContract("Lottery", [NetworkAirnode], {});

  await lottery.waitForDeployment();

  console.log(`Lottery contract address: ${lottery.target}`);

  console.log("Verifying contract...");

  // Wait for a few confirmations before verifying
  await new Promise(resolve => setTimeout(resolve, 60000));

  // Verify contract
  await run("verify:verify", {
    address: lottery.target,
    constructorArguments: [NetworkAirnode],
  });

  let sponsorAddress;
  sponsorAddress = await deriveSponsorWalletAddress(xpub, airnodeRrp, (lottery.target).toString()) as string;

  console.log("Sponsor Wallet:", sponsorAddress);

  /* etheres 5.7.3 compatability
  // Sending ETH to the sponsorAddress
  const amountToSend = ethers.utils.parseEther("1"); // Sending 1 ETH

  const signer = ethers.provider.getSigner(); // Assuming the signer (sender of ETH) is the first account in the Hardhat network
  const tx = await signer.sendTransaction({
    to: sponsorAddress,
    value: amountToSend,
  });

  console.log(`Transaction hash: ${tx.hash}`);
  
  // Wait for transaction to be mined
  const receipt = await tx.wait();
  
  console.log(`Transaction confirmed in block: ${receipt.blockNumber}`);
  */

  // Sending ETH to the sponsorAddress
  const amountToSend = ethers.parseEther("0.0001");  // choose how much you want to send to the sponsor contract

  const signer = ethers.provider.getSigner(); // Assuming the signer (sender of ETH) is the first account in the Hardhat network
  const tx = (await signer).sendTransaction({
    to: sponsorAddress,
    value: amountToSend,
  });

  console.log(`Transaction hash: ${(await tx).hash}`);
  
  // Wait for transaction to be mined
  (await tx).isMined();
  console.log(`Gas sent to sponsor contract`);

  await lottery.setRequestParameters(airnodeRrp, endpoint, sponsorAddress);
  console.log(`Request parameters set`);
}


// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
