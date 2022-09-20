import * as dotenv from "dotenv";
import { Contract, ContractFactory } from "ethers";
import { ethers, upgrades } from "hardhat";

async function main(): Promise<void> {
    // const Treasury: ContractFactory = await ethers.getContractFactory("TreasuryUpgradeable");
    // const treasury: Contract = await upgrades.deployProxy(
    //   Treasury,
    //   [process.env.VERIFIER],
    //   { kind: "uups", initializer: "init" },
    // );
    // await treasury.deployed();
    // console.log("Treasury deployed to : ", treasury.address);

    const Business: ContractFactory = await ethers.getContractFactory(
        "BusinessUpgradeable",
    );
    const business: Contract = await upgrades.deployProxy(Business, [], {
        kind: "uups",
        initializer: "init",
    });
    await business.deployed();
    console.log("Business deployed to : ", business.address);

    // const ERC20Test: ContractFactory = await ethers.getContractFactory("ERC20Test");
    // const erc20Test: Contract = await ERC20Test.deploy(
    //   "PaymentToken", "PMT"
    // );
    // await erc20Test.deployed();
    // console.log("ERC20Test deployed to : ", erc20Test.address);

    // const RentableNFC: ContractFactory = await ethers.getContractFactory("RentableNFCUpgradeable");
    // const rentableNFC: Contract = await upgrades.deployProxy(
    //   RentableNFC,
    //   ["RentableNFC", "RNFC", "https://example/token/", 10000, 100, erc20Test.address, "0x2A42bde6C299a02D98E33E1F1BB3886797cbaECC", "0xf6D3B4Fbd90715976587b2058ABeA5F2D0cB517f"],
    //   { kind: "uups", initializer: "init" },
    // );
    // await rentableNFC.deployed();
    // console.log("RentableNFC deployed to : ", rentableNFC.address);
}

main()
    .then(() => process.exit(0))
    .catch((error: Error) => {
        console.error(error);
        process.exit(1);
    });
