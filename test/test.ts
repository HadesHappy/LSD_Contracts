import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import hre from 'hardhat';
import { expect } from "chai";
import { ethers } from "hardhat";

describe("LSD", function () {
  // Contracts are deployed using the first signer/account by default
  async function deployLSDContracts() {
    // Contracts are deployed using the first signer/account by default
    const [owner, otherAccount] = await ethers.getSigners();
    const LsdStorage = await ethers.getContractFactory("LSDStorage");
    const LsdOwner = await ethers.getContractFactory("LSDOwner");
    const LsdUpdateBalance = await ethers.getContractFactory("LSDUpdateBalance");
    const LsdDepositPool = await ethers.getContractFactory("LSDDepositPool");
    const LsdTokenLSETH = await ethers.getContractFactory("LSDTokenLSETH");
    const LsdLIDOVault = await ethers.getContractFactory("LSDLIDOVault");
    const LsdTokenVELSD = await ethers.getContractFactory("LSDTokenVELSD");
    const LsdStakingPool = await ethers.getContractFactory("LSDStakingPool");
    const LsdToken = await ethers.getContractFactory("LSDToken");
    
    // deploy

    const lsdStorage = await LsdStorage.deploy();
    const lsdOwner = await LsdOwner.deploy(lsdStorage.address);
    const lsdUpdateBalance = await LsdUpdateBalance.deploy(lsdStorage.address);
    const lsdDepositPool = await LsdDepositPool.deploy(lsdStorage.address);
    const lsdStakingPool = await LsdStakingPool.deploy(lsdStorage.address);
    const lsdLIDOVault = await LsdLIDOVault.deploy(lsdStorage.address);
    const lsdTokenLSETH = await LsdTokenLSETH.deploy(lsdStorage.address);
    const lsdTokenVELSD = await LsdTokenVELSD.deploy(lsdStorage.address);
    const lsdToken = await LsdToken.deploy();
    
    // console addresses

    console.log("storage contract address: ", lsdStorage.address);
    console.log("owner contract address: ", lsdOwner.address);
    console.log("updateBalance contract address: ", lsdUpdateBalance.address);
    console.log("depositPool contract address: ", lsdDepositPool.address);
    console.log("token LS-ETH contract address: ", lsdTokenLSETH.address);
    console.log("token VE-LSD contract address: ", lsdTokenVELSD.address);
    console.log("lido vault contract address: ", lsdLIDOVault.address);
    console.log("staking pool contract address: ", lsdStakingPool.address);
    console.log("lsdToken address: ", lsdToken.address);

    // Add Contract to the Storage
    await lsdOwner.upgrade("addContract", "lsdOwner", '1', lsdOwner.address);
    await lsdOwner.upgrade("addContract", "lsdUpdateBalance", '1', lsdUpdateBalance.address);
    await lsdOwner.upgrade("addContract", "lsdDepositPool", '1', lsdDepositPool.address);
    await lsdOwner.upgrade("addContract", "lsdStakingPool", '1', lsdStakingPool.address);
    await lsdOwner.upgrade("addContract", "lsdTokenLSETH", '1', lsdTokenLSETH.address);
    await lsdOwner.upgrade("addContract", "lsdTokenVELSD", '1', lsdTokenVELSD.address);
    await lsdOwner.upgrade("addContract", "lsdLIDOVault", '1', lsdLIDOVault.address);
    await lsdOwner.upgrade("addContract", "lsdStorage", '1', lsdStorage.address);
    await lsdOwner.upgrade("addContract", "lsdToken", '1', lsdToken.address);
    await lsdOwner.upgrade("addContract", "lsdDaoContract", '1', otherAccount.address);
    await lsdOwner.upgrade("addContract", "lido", '1', "0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84");
    await lsdOwner.upgrade("addContract", "weth", '1', "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2");
    await lsdOwner.upgrade("addContract", "uniswapRouter", '1', "0x7a250d5630b4cf539739df2c5dacb4c659f2488d");

    // Set Owner Settings
    await lsdOwner.setLIDOApy(4);
    await lsdOwner.setApy(5);
    await lsdOwner.setMinimumDepositAmount(ethers.utils.parseEther('0.2'));
    await lsdOwner.setMultiplier(5);
    await lsdOwner.setStakeApr(20);

    return { lsdStorage, lsdOwner, lsdUpdateBalance, lsdDepositPool, lsdStakingPool, lsdToken, lsdTokenVELSD, lsdTokenLSETH, owner, otherAccount };
  }

  describe('deploy & guardian', async function () {
    // test for lsd storage
    it('guardian', async function () {
      // keys
      // console.log('lido key: ', ethers.utils.keccak256(ethers.utils.solidityPack(['string', 'string'], ["contract.address", "lido"])));
      // console.log('uniswapRouter key: ', ethers.utils.keccak256(ethers.utils.solidityPack(['string', 'string'], ["contract.address", "uniswapRouter"])));
      // console.log('weth key: ', ethers.utils.keccak256(ethers.utils.solidityPack(['string', 'string'], ["contract.address", "weth"])));
      // console.log('rp key: ', ethers.utils.keccak256(ethers.utils.solidityPack(['string', 'string'], ["contract.address", "rocketDepositPool"])));
      // console.log('rpETH key: ', ethers.utils.keccak256(ethers.utils.solidityPack(['string', 'string'], ["contract.address", "rocketTokenRETH"])));
      // console.log('lsd deposit pool key: ', ethers.utils.keccak256(ethers.utils.solidityPack(['string', 'string'], ["contract.address", "lsdDepositPool"])));
      // console.log('lsd LIDO Vault key: ', ethers.utils.keccak256(ethers.utils.solidityPack(['string', 'string'], ["contract.address", "lsdLIDOVault"])));
      // console.log('lsd update balance key: ', ethers.utils.keccak256(ethers.utils.solidityPack(['string', 'string'], ["contract.address", "lsdUpdateBalance"])));
      // console.log('lsd owner key: ', ethers.utils.keccak256(ethers.utils.solidityPack(['string', 'string'], ["contract.address", "lsdOwner"])));
      // console.log('lsd VELSD key: ', ethers.utils.keccak256(ethers.utils.solidityPack(['string', 'string'], ["contract.address", "lsdTokenVELSD"])));
      // console.log('lsd LSETH key: ', ethers.utils.keccak256(ethers.utils.solidityPack(['string', 'string'], ["contract.address", "lsdTokenLSETH"])));
      // const { lsdStorage, lsdDepositPool, owner, otherAccount } = await loadFixture(deployLSDContracts);
      // lsdDepositPool.deposit()
      // console.log('depolyed address: ', lsdStorage.address);
      // console.log('guardian address: ', await lsdStorage.getGuardian());
      // await lsdStorage.setGuardian(otherAccount.address);
      // await lsdStorage.connect(otherAccount).confirmGuardian();
      // console.log('new guardian: ', await lsdStorage.getGuardian());
      // console.log('depolyed status: ', await lsdStorage.getDeployedStatus());
      // await lsdStorage.connect(otherAccount).setDeployedStatus();
      // console.log('depolyed status: ', await lsdStorage.getDeployedStatus());

    });
    // test for lsd owner
    it('owner', async function () {
      // const { lsdOwner, owner, otherAccount } = await loadFixture(deployLSDContracts);
      // // test isLock
      // console.log('isLock: ', await lsdOwner.getIsLock());
      // await lsdOwner.setIsLock(true);
      // console.log('isLock: ', await lsdOwner.getIsLock());
      // // deposit enabled 
      // console.log('deposit enabled: ', await lsdOwner.getDepositEnabled())
      // await lsdOwner.setDepositEnabled(true)
      // console.log('deposit enabled: ', await lsdOwner.getDepositEnabled());

      // // APYS
      // console.log('rp apy: ', await lsdOwner.getRPApy());
      // await lsdOwner.setRPApy(10);
      // console.log('rp apy: ', await lsdOwner.getRPApy());

      // console.log('lido apy: ', await lsdOwner.getLIDOApy());
      // await lsdOwner.setLIDOApy(10);
      // console.log('lido apy: ', await lsdOwner.getLIDOApy());

      // console.log('swise apy: ', await lsdOwner.getSWISEApy());
      // await lsdOwner.setSWISEApy(10);
      // console.log('swise apy: ', await lsdOwner.getSWISEApy());

      // console.log('minimum deposit amount: ', await lsdOwner.getMinimumDepositAmount());
      // await lsdOwner.setMinimumDepositAmount(10);
      // console.log('minimum deposit amount: ', await lsdOwner.getMinimumDepositAmount());
    });

    it("deposit", async function () {
      // const { lsdDepositPool, lsdTokenLSETH, owner, otherAccount } = await loadFixture(deployLSDContracts);

      // await lsdDepositPool.deposit({ value: ethers.utils.parseEther('1') });
      // console.log('balance: ', await lsdTokenLSETH.balanceOf(owner.address));

      // const ONE_DAY = 60 * 60 * 24;
      // await time.increase(365 * ONE_DAY);
      // await lsdDepositPool.deposit({ value: ethers.utils.parseEther('1') });
      // console.log('balance: ', await lsdTokenLSETH.balanceOf(owner.address));

      // await time.increase(365 * ONE_DAY);
      // await lsdTokenLSETH.transfer(otherAccount.address, ethers.utils.parseEther('1'));
      // console.log('balance: ', await lsdTokenLSETH.balanceOf(owner.address));
      // console.log('balance: ', await lsdTokenLSETH.balanceOf(otherAccount.address));

      // await lsdDepositPool.deposit({ value: ethers.utils.parseEther('1') });
      // console.log('balance: ', await lsdTokenLSETH.balanceOf(owner.address));
    });

    it("swap VE-LSD", async function () {
      // const { lsdDepositPool, lsdTokenLSETH, lsdTokenVELSD, owner, otherAccount } = await loadFixture(deployLSDContracts);
      // await lsdDepositPool.deposit({ value: ethers.utils.parseEther('1') });
      // console.log('owner balance: ', await lsdTokenLSETH.balanceOf(owner.address));

      // // lsdTokenLSETH.approve(lsdTokenVELSD.address, ethers.utils.parseEther('1'));
      // // await lsdTokenVELSD.mint(ethers.utils.parseEther('1'));

      // // console.log('VE-LSD balance of the owner: ', await lsdTokenVELSD.balanceOf(owner.address));
      // // console.log('LS-ETH balance of the owner: ', await lsdTokenLSETH.balanceOf(owner.address));

      // // await lsdTokenVELSD.transfer(otherAccount.address, ethers.utils.parseEther('0.5'));
      // // console.log('VE-LSD balance of the owner: ', await lsdTokenVELSD.balanceOf(owner.address));

      // console.log('exchange rate: ', await lsdTokenLSETH.getExchangeRate());
      // const ONE_DAY = 60 * 60 * 24;
      // time.increase(365 * ONE_DAY);

      // await lsdDepositPool.deposit({ value: ethers.utils.parseEther('1') });
      // console.log('LS-ETH balance of the owner: ', await lsdTokenLSETH.balanceOf(owner.address));

      // console.log('exchange rate: ', await lsdTokenLSETH.getExchangeRate());

      // await lsdTokenLSETH.burn(ethers.utils.parseEther('0.5'));
      // console.log('LS-ETH balance of the owner: ', await lsdTokenLSETH.balanceOf(owner.address));
    });

    it('deposit & withdraw', async function() {
      // const {lsdDepositPool, lsdTokenLSETH, rp, owner, otherAccount} = await loadFixture(deployLSDContracts);
      // console.log('eth balance: ', ethers.utils.formatEther(await owner.getBalance()));
      // await lsdDepositPool.deposit({value: ethers.utils.parseEther('1')});
      // console.log('owner LS-ETH balance: ', await lsdTokenLSETH.balanceOf(owner.address));
      // console.log('rp pool balance', await rp.getContractBalance());
      // time.increase(365*24*60*60);
      // await lsdTokenLSETH.transfer(otherAccount.address, ethers.utils.parseEther('0.1'));
      // await lsdTokenLSETH.burn(ethers.utils.parseEther('0.5'));
      // console.log('owner LS-ETH balance: ', await lsdTokenLSETH.balanceOf(owner.address));
      // console.log('rp pool balance', await rp.getContractBalance());
      // console.log('eth balance: ', ethers.utils.formatEther(await owner.getBalance()));
      
    })

    it('staking', async function(){
      const { lsdStakingPool, lsdToken, lsdTokenVELSD, owner, otherAccount } = await loadFixture(deployLSDContracts);
      await lsdToken.mint(ethers.utils.parseUnits('1', 9));
      await lsdToken.approve(lsdStakingPool.address, ethers.utils.parseUnits('1', 10));
      await lsdStakingPool.stakeLSD(ethers.utils.parseUnits('1', 9));
      await time.increase(365 * 24 * 60 * 60);
      // console.log("first: ", Number(await lsdStakingPool.getClaimAmount(owner.address)));

      await time.increase(365 * 24 * 60 * 60);
      await lsdToken.mint(ethers.utils.parseUnits('1', 9));
      await lsdStakingPool.stakeLSD(ethers.utils.parseUnits('1', 9));
      console.log("user: ", await lsdStakingPool.getUser(owner.address))
      console.log("before claim bonus: ", Number(await lsdStakingPool.getClaimAmount(owner.address)));

      // await time.increase(365 * 24 * 60 * 60);
      await lsdStakingPool.claim();
      console.log("after claim bonus: ", Number(await lsdStakingPool.getClaimAmount(owner.address)));
      // console.log("user: ", await lsdStakingPool.getUser(owner.address))
      await time.increase(365 * 24 * 60 * 60);
      console.log("after one year claim bonus: ", Number(await lsdStakingPool.getClaimAmount(owner.address)));

      console.log('before unstake: ', Number(await lsdTokenVELSD.balanceOf(owner.address)));
      console.log('before user: ', await lsdStakingPool.getUser(owner.address));
      await lsdStakingPool.unstakeLSD(ethers.utils.parseUnits("1", 9));
      console.log("after unstake: ", await lsdStakingPool.getUser(owner.address))
      console.log('after unstake: ', Number(await lsdTokenVELSD.balanceOf(owner.address)))
      await time.increase(182 * 24 * 60 * 60);
      console.log("after one year claim bonus: ", Number(await lsdStakingPool.getClaimAmount(owner.address)));

      // await lsdStakingPool.unstakeLSD(ethers.utils.parseUnits('1', 9));
      // await lsdTokenVELSD.transfer(otherAccount.address, ethers.utils.parseUnits('1', 9));
    })
  })
});