import { ethers } from "hardhat";

async function main() {
  const LsdStorage = await ethers.getContractFactory("LSDStorage");
  const LsdOwner = await ethers.getContractFactory("LSDOwner");
  const LsdUpdateBalance = await ethers.getContractFactory("LSDUpdateBalance");
  const LsdDepositPool = await ethers.getContractFactory("LSDDepositPool");
  const LsdTokenLSETH = await ethers.getContractFactory("LSDTokenLSETH");
  const LsdTokenVELSD = await ethers.getContractFactory("LSDTokenVELSD");
  const LsdRPVault = await ethers.getContractFactory("LSDRPVault");
  const LsdLIDOVault = await ethers.getContractFactory("LSDLIDOVault");

  const lsdStorage = await LsdStorage.deploy();
  const lsdOwner = await LsdOwner.deploy(lsdStorage.address);
  const lsdUpdateBalance = await LsdUpdateBalance.deploy(lsdStorage.address);
  const lsdDepositPool = await LsdDepositPool.deploy(lsdStorage.address);
  const lsdTokenLSETH = await LsdTokenLSETH.deploy(lsdStorage.address);
  const lsdTokenVELSD = await LsdTokenVELSD.deploy(lsdStorage.address, "VE-LSD", "veLSD");
  const lsdRPVault = await LsdRPVault.deploy(lsdStorage.address);
  const lsdLIDOVault = await LsdLIDOVault.deploy(lsdStorage.address);

  console.log(`LSD Storage deployed to ${lsdStorage.address}`);
  console.log(`LSD Owner deployed to ${lsdOwner.address}`);
  console.log(`LSD Update Balance deployed to ${lsdUpdateBalance.address}`);
  console.log(`LSD Deposit Pool deployed to ${lsdDepositPool.address}`);
  console.log(`LSD TokenLSETH deployed to ${lsdTokenLSETH.address}`);
  console.log(`LSD TokenVELSD deployed to ${lsdTokenVELSD.address}`);
  console.log(`LSD RP Vault deployed to ${lsdRPVault.address}`);
  console.log(`LSD LIDO Vault Contract deployed to ${lsdLIDOVault.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
