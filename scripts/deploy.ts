import { ethers } from "hardhat";

async function main() {
  // const LsdStorage = await ethers.getContractFactory("LSDStorage");
  // const LsdOwner = await ethers.getContractFactory("LSDOwner");
  // const LsdUpdateBalance = await ethers.getContractFactory("LSDUpdateBalance");
  // const LsdDepositPool = await ethers.getContractFactory("LSDDepositPool");
  // const LsdTokenLSETH = await ethers.getContractFactory("LSDTokenLSETH");
  const Lsd = await ethers.getContractFactory("LSD");
  // const LsdRPVault = await ethers.getContractFactory("LSDRPVault");
  // const LsdLIDOVault = await ethers.getContractFactory("LSDLIDOVault");

  // const lsdStorage = await LsdStorage.deploy();
  // const lsdOwner = await LsdOwner.deploy(lsdStorage.address);
  // const lsdUpdateBalance = await LsdUpdateBalance.deploy("0x01AB550aeFc3a892F191e6382328CdD44503c408");
  // const lsdDepositPool = await LsdDepositPool.deploy(lsdStorage.address);
  // const lsdTokenLSETH = await LsdTokenLSETH.deploy(lsdStorage.address);
  const lsd = await Lsd.deploy("LSD", "LSD");
  // const lsdRPVault = await LsdRPVault.deploy(lsdStorage.address);
  // const lsdLIDOVault = await LsdLIDOVault.deploy("0x6E537840ED1320ef1693386961eB5BdA8C2a0CF9");

  // console.log(`LSD Storage deployed to ${lsdStorage.address}`);
  // console.log(`LSD Owner deployed to ${lsdOwner.address}`);
  // console.log(`LSD Update Balance deployed to ${lsdUpdateBalance.address}`);
  // console.log(`LSD Deposit Pool deployed to ${lsdDepositPool.address}`);
  // console.log(`LSD TokenLSETH deployed to ${lsdTokenLSETH.address}`);
  console.log(`LSD deployed to ${lsd.address}`);
  // console.log(`LSD RP Vault deployed to ${lsdRPVault.address}`);
  // console.log(`LSD LIDO Vault Contract deployed to ${lsdLIDOVault.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
