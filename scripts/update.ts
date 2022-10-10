import { Contract, ContractFactory } from "ethers";
import * as dotenv from "dotenv";
import { ethers, upgrades } from "hardhat";

async function main(): Promise<void> {
    const Treasury: ContractFactory = await ethers.getContractFactory("TreasuryUpgradeable");
}

main()
    .then(() => process.exit(0))
    .catch((error: Error) => {
        console.error(error);
        process.exit(1);
    });