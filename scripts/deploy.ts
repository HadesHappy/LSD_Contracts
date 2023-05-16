import { ethers } from "hardhat";

async function main() {
  // const LsdStorage = await ethers.getContractFactory("LSDStorage");
  // const LsdOwner = await ethers.getContractFactory("LSDOwner");
  // const LsdUpdateBalance = await ethers.getContractFactory("LSDUpdateBalance");
  // // pools
  // const LsdDepositPool = await ethers.getContractFactory("LSDDepositPool");

  // const LsdLpTokenStaking = await ethers.getContractFactory("LSDLpTokenStaking");
  const LsdTokenStaking = await ethers.getContractFactory("LSDTokenStaking");
  // const LsdTokenVault = await ethers.getContractFactory("LSDTokenVault");
  // const LsdRewardsVault = await ethers.getContractFactory("LSDRewardsVault");
  // tokens
  // const LsdTokenLSETH = await ethers.getContractFactory("LSDTokenLSETH");
  // const LsdTokenVELSD = await ethers.getContractFactory("LSDTokenVELSD");
  // // vault
  // const LsdLIDOVault = await ethers.getContractFactory("LSDLIDOVault");
  /**
   * deploy
   */
  // const lsdStorage = await LsdStorage.deploy();
  // const lsdOwner = await LsdOwner.deploy("0xC1D358ad6580F232796262aAf3F2EE2FA5E9b484");
  // const lsdUpdateBalance = await LsdUpdateBalance.deploy("0xC1D358ad6580F232796262aAf3F2EE2FA5E9b484");

  // const lsdDepositPool = await LsdDepositPool.deploy("0xC1D358ad6580F232796262aAf3F2EE2FA5E9b484");
  // const lsdLpTokenStaking = await LsdLpTokenStaking.deploy("0xC1D358ad6580F232796262aAf3F2EE2FA5E9b484");
  const lsdTokenStaking = await LsdTokenStaking.deploy("0xC1D358ad6580F232796262aAf3F2EE2FA5E9b484");
  // const lsdTokenVault = await LsdTokenVault.deploy("0xC1D358ad6580F232796262aAf3F2EE2FA5E9b484");
  // const lsdRewardsVault = await LsdRewardsVault.deploy("0xC1D358ad6580F232796262aAf3F2EE2FA5E9b484");

  // const lsdTokenLSETH = await LsdTokenLSETH.deploy(lsdStorage.address);
  // const lsdTokenVELSD = await LsdTokenVELSD.deploy(lsdStorage.address);

  // // const lsdRPVault = await LsdRPVault.deploy(lsdStorage.address);
  // const lsdLIDOVault = await LsdLIDOVault.deploy("0xC1D358ad6580F232796262aAf3F2EE2FA5E9b484");

  // console.log(`LSD Storage deployed to ${lsdStorage.address}`);
  // console.log(`LSD Owner deployed to ${lsdOwner.address}`);
  // console.log(`LSD Update Balance deployed to ${lsdUpdateBalance.address}`);

  // console.log(`LSD Deposit Pool deployed to ${lsdDepositPool.address}`);
  console.log(`LSD Staking Pool deployed to ${lsdTokenStaking.address}`);
  // console.log(`LSD Token Vault deployed to ${lsdTokenVault.address}`);
  // console.log(`LSD Rewards Vault deployed to ${lsdRewardsVault.address}`);
  // console.log(`LP Token Staking deployed to ${lsdLpTokenStaking.address}`);

  // console.log(`LSD TokenLSETH deployed to ${lsdTokenLSETH.address}`);
  // console.log(`LSD TokenVELSD deployed to ${lsdTokenVELSD.address}`);
  // // console.log(`LSD RP Vault deployed to ${lsdRPVault.address}`);
  // console.log(`LSD LIDO Vault Contract deployed to ${lsdLIDOVault.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
