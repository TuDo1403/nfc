import { Contract, ContractFactory } from "ethers";
import { ethers, upgrades } from "hardhat";

import * as dotenv from "dotenv"

async function main(): Promise<void> {
    // const Treasury: ContractFactory = await ethers.getContractFactory("TreasuryUpgradeable");
    // const treasury: Contract = await upgrades.deployProxy(
    //   Treasury,
    //   [process.env.VERIFIER],
    //   { kind: "uups", initializer: "init" },
    // );
    // await treasury.deployed();
    // console.log("Treasury deployed to : ", treasury.address);

    // const Business: ContractFactory = await ethers.getContractFactory("BusinessUpgradeable");
    // const business: Contract = await upgrades.upgradeProxy(
    //     "0xf6D3B4Fbd90715976587b2058ABeA5F2D0cB517f",
    //     Business
    // );
    // await business.deployed();
    // console.log("Business upgraded to : ", await upgrades.erc1967.getImplementationAddress(business.address));

    //   const ERC20Test: ContractFactory = await ethers.getContractFactory("ERC20Test");
    //   const erc20Test: Contract = await ERC20Test.deploy(
    //     "PaymentToken", "PMT"
    //   );
    //   await erc20Test.deployed();
    //   console.log("ERC20Test deployed to : ", erc20Test.address);

    const RentableNFC: ContractFactory = await ethers.getContractFactory("RentableNFCUpgradeable");
    const rentableNFC: Contract = await upgrades.upgradeProxy(
        "0xf0333664C989E0E7b26fe84f0796c2f4064Be309",
        RentableNFC
    );
    await rentableNFC.deployed();
    console.log("RentableNFC upgraded to : ", await upgrades.erc1967.getImplementationAddress(rentableNFC.address));
}

main()
    .then(() => process.exit(0))
    .catch((error: Error) => {
        console.error(error);
        process.exit(1);
    });