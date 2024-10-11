import { bigint } from "hardhat/internal/core/params/argumentTypes";

const { ethers } = require("hardhat");

let pool = "0x72C038736F191e0868A05bFD6e0a6D6DFE8c0A3C";
let fsfi = "0x0f78315aaC4F053Cf3D05999FD0A3bC3d40ab326";
let usdtPool = "0xEBE2E725ef9f2f91182886223ef5fB576AC41808";

// let fsfi = "0xB07c62E2a4E3da8465fa207965da12787b9188fc";
// let usdtPool = "0xa00Ae2a3aeFd3002EDE22523E12BF28D4676596A";

let usdt = "0xaa8e23fb1079ea71e0a56f48a2aa51851d8433d0";
let usdc = "0x94a9D9AC8a22534E3FaCa9F4e7F2E2cf85d5E4C8";
let wbtc = "0x29f2D40B0605204364af54EC677bD022dA425d03";
let wETH = "0xC558DBdd856501FCd9aaF1E62eae57A9F0629a3c";
let aWBTC = "0x1804Bf30507dc2EB3bDEbbbdd859991EAeF6EefF";
let aWETH = "0x5b071b590a59395fE4025A0Ccc1FcC931AAc1830";
let PoolAddressesProviderAave = "0x012bAC54348C0E635dCAc9D5FB99f06F24136C9A";
let btcAgrr = "0x2B1EdE85Ea8105e638429a9B3Ec621d1A7939597";

async function approveUsdc(AMOUNT: any) {
  const signer = await ethers.provider.getSigner();
  console.log("signer", await signer.getAddress());

  const iUsdc = await ethers.getContractAt("IERC20Standard", usdc, signer);
  console.log(await iUsdc.getAddress());
  const tx = await iUsdc.approve(pool, AMOUNT);
  await tx.wait(1);
  const balance = await iUsdc.allowance(
    "0x17883e3728E7bB528b542B8AAb354022eD20C149",
    pool
  );
  console.log(`Got ${(balance / BigInt(1e6)).toString()} USDC.`);
}

async function approveUsdt(AMOUNT: any) {
  const signer = await ethers.provider.getSigner();
  console.log("signer", await signer.getAddress());

  const iUsdc = await ethers.getContractAt("IERC20Standard", usdt, signer);
  console.log(await iUsdc.getAddress());
  const tx = await iUsdc.approve(usdtPool, AMOUNT);
  await tx.wait(1);
  const balance = await iUsdc.allowance(
    "0x17883e3728E7bB528b542B8AAb354022eD20C149",
    usdtPool
  );
  console.log(`Got ${(balance / BigInt(1e6)).toString()} USDT.`);
}

async function approveLoanUsdc(AMOUNT: any) {
  const signer = await ethers.provider.getSigner();
  console.log("signer", await signer.getAddress());

  const iUsdc = await ethers.getContractAt("IERC20Standard", usdc, signer);
  console.log(await iUsdc.getAddress());
  const tx = await iUsdc.approve(fsfi, AMOUNT);
  await tx.wait(1);
  const balance = await iUsdc.allowance(
    "0x17883e3728E7bB528b542B8AAb354022eD20C149",
    fsfi
  );
  console.log(`Got ${(balance / BigInt(1e6)).toString()} USDC.`);
}

async function approveLoanUsdt(AMOUNT: any) {
  const signer = await ethers.provider.getSigner();
  console.log("signer", await signer.getAddress());

  const iUsdc = await ethers.getContractAt("IERC20Standard", usdt, signer);
  console.log(await iUsdc.getAddress());
  const tx = await iUsdc.approve(fsfi, AMOUNT);
  await tx.wait(1);
  const balance = await iUsdc.allowance(
    "0x17883e3728E7bB528b542B8AAb354022eD20C149",
    fsfi
  );
  console.log(`Got ${(balance / BigInt(1e6)).toString()} USDT.`);
}

async function approveWBTC(AMOUNT: any) {
  const signer = await ethers.provider.getSigner();
  console.log("signer", await signer.getAddress());

  const iUsdc = await ethers.getContractAt("IERC20Standard", wbtc, signer);

  const tx = await iUsdc.approve(fsfi, AMOUNT);
  await tx.wait(1);
  const balance = await iUsdc.allowance(
    "0x17883e3728E7bB528b542B8AAb354022eD20C149",
    fsfi
  );
  console.log(`Got ${(balance / BigInt(1e6)).toString()} WBTC.`);
}

async function allowanceUsdc() {
  const signer = await ethers.provider.getSigner();
  console.log("signer", await signer.getAddress());

  const iUsdc = await ethers.getContractAt("IERC20Standard", usdc, signer);
  const balance = await iUsdc.allowance(
    "0x17883e3728E7bB528b542B8AAb354022eD20C149",
    usdc
  );
  console.log(`Got ${(balance / BigInt(1e6)).toString()} USDC.`);
}

async function allowanceUsdt() {
  const signer = await ethers.provider.getSigner();
  console.log("signer", await signer.getAddress());

  const iUsdc = await ethers.getContractAt("IERC20Standard", usdt, signer);
  const balance = await iUsdc.allowance(
    "0x17883e3728E7bB528b542B8AAb354022eD20C149",
    usdc
  );
  console.log(`Got ${(balance / BigInt(1e6)).toString()} USDT.`);
}

async function supplyUsdc(AMOUNT: any) {
  const signer = await ethers.provider.getSigner();
  console.log("signer", await signer.getAddress());

  const iUsdc = await ethers.getContractAt("IFSFIPool", pool, signer);

  const tx = await iUsdc.supply(AMOUNT);
  await tx.wait(1);
  const balance = await iUsdc.balanceOf(
    "0x17883e3728E7bB528b542B8AAb354022eD20C149"
  );
  console.log(`Got ${(balance / BigInt(1e6)).toString()} USDC.`);
}

async function supplyUsdt(AMOUNT: any) {
  const signer = await ethers.provider.getSigner();
  console.log("signer", await signer.getAddress());

  const iUsdc = await ethers.getContractAt("IFSFIPool", usdtPool, signer);

  const tx = await iUsdc.supply(AMOUNT);
  await tx.wait(1);
  const balance = await iUsdc.balanceOf(
    "0x17883e3728E7bB528b542B8AAb354022eD20C149"
  );
  console.log(`Got ${(balance / BigInt(1e6)).toString()} USDT.`);
}

async function repay(loanId: any, AMOUNT: any) {
  const signer = await ethers.provider.getSigner();
  console.log("signer", await signer.getAddress());

  const iUsdc = await ethers.getContractAt("IFSFI", fsfi, signer);

  const tx = await iUsdc.repayLoan(loanId, AMOUNT, usdc);
  console.log(tx);
  await tx.wait(1);
  const iUsdc2 = await ethers.getContractAt("IFSFIPool", pool, signer);
  let balance = await iUsdc2.getCurrentLoan(loanId);
  console.log(`Got ${balance}`);
}

async function repayUSDT(loanId: any, AMOUNT: any) {
  const signer = await ethers.provider.getSigner();
  console.log("signer", await signer.getAddress());

  const iUsdc = await ethers.getContractAt("IFSFI", fsfi, signer);

  const tx = await iUsdc.repayLoan(loanId, AMOUNT, usdt);
  console.log(tx);
  await tx.wait(1);
  const iUsdc2 = await ethers.getContractAt("IFSFIPool", usdtPool, signer);
  let balance = await iUsdc2.getCurrentLoan(loanId);
  console.log(`Got ${balance}`);
}

async function changeWbtcprice(price: any) {
  const signer = await ethers.provider.getSigner();
  console.log("signer", await signer.getAddress());
  const iUsdc = await ethers.getContractAt("MockAggregator", btcAgrr, signer);
  await iUsdc.setPrice(price);
}

async function createLoan() {
  const amountUsdc = ethers.parseUnits("1", 6);
  const amountWbtc = ethers.parseUnits("0.1", 8);
  const signer = await ethers.provider.getSigner();
  console.log("signer", await signer.getAddress());

  const iUsdc = await ethers.getContractAt("IFSFI", fsfi, signer);

  const tx = await iUsdc.createLoan(
    amountUsdc,
    usdc,
    amountWbtc,
    wbtc,
    true,
    false
  );
  await tx.wait(1);
  const ids = await iUsdc.getLoanIds(
    "0x17883e3728E7bB528b542B8AAb354022eD20C149"
  );
  console.log(`Got ${ids}`);
}

async function createLoanUSDT() {
  const amountUsdc = ethers.parseUnits("0.1", 6);
  const amountWbtc = ethers.parseUnits("0.1", 8);
  const signer = await ethers.provider.getSigner();
  console.log("signer", await signer.getAddress());

  const iUsdc = await ethers.getContractAt("IFSFI", fsfi, signer);

  const tx = await iUsdc.createLoan(
    amountUsdc,
    usdt,
    amountWbtc,
    wbtc,
    true,
    false
  );
  await tx.wait(1);
  const ids = await iUsdc.getLoanIds(
    "0x17883e3728E7bB528b542B8AAb354022eD20C149"
  );
  console.log(`Got ${ids}`);
}

async function createLoanNoStake() {
  const amountUsdc = ethers.parseUnits("1", 6);
  const amountWbtc = ethers.parseUnits("0.1", 8);
  const signer = await ethers.provider.getSigner();
  console.log("signer", await signer.getAddress());

  const iUsdc = await ethers.getContractAt("IFSFI", fsfi, signer);

  const tx = await iUsdc.createLoan(
    amountUsdc,
    usdc,
    amountWbtc,
    wbtc,
    false,
    false
  );
  await tx.wait(1);
  const ids = await iUsdc.getLoanIds(
    "0x17883e3728E7bB528b542B8AAb354022eD20C149"
  );
  console.log(`Got ${ids}`);
}

async function withdrawCollateral(loanId: any) {
  const signer = await ethers.provider.getSigner();
  console.log("signer", await signer.getAddress());

  const iUsdc = await ethers.getContractAt("IFSFI", fsfi, signer);

  const tx = await iUsdc.withdrawAllCollateral(loanId, false);
}

async function liquidate(loanId: any) {
  const signer = await ethers.provider.getSigner();
  console.log("signer", await signer.getAddress());

  const iUsdc = await ethers.getContractAt("IFSFI", fsfi, signer);

  const tx = await iUsdc.liquidate(loanId);
}

async function getCurrentLoan(loanId: any) {
  const signer = await ethers.provider.getSigner();
  console.log("signer", await signer.getAddress());

  const iUsdc = await ethers.getContractAt("IFSFIPool", pool, signer);
  let balance = await iUsdc.getCurrentLoan(loanId);
  console.log(`Got ${balance}`);
}

async function getHealthFactor(usdcAmount: any, wbtcAmount: any, loanId: any) {
  const signer = await ethers.provider.getSigner();
  console.log("signer", await signer.getAddress());

  const iUsdc = await ethers.getContractAt("IFSFI", fsfi, signer);

  const healthFactor = await iUsdc.getHealthFactor(BigInt(loanId));
  console.log(`Got ${healthFactor}`);

  if (usdcAmount) {
    const repayHealthFactor = await iUsdc.repayHealthFactor(
      BigInt(loanId),
      usdcAmount
    );
    console.log(`Got ${repayHealthFactor}`);
  }

  if (wbtcAmount) {
    const addCollateralHealthFactor = await iUsdc.addCollateralHealthFactor(
      BigInt(loanId),
      wbtcAmount
    );
    console.log(`Got ${addCollateralHealthFactor}`);
  }
}

async function getMinimumCollateral(usdcAmount: any) {
  const signer = await ethers.provider.getSigner();
  console.log("signer", await signer.getAddress());

  const aggrWBTC = await ethers.getContractAt(
    "MockAggregator",
    "0x2B1EdE85Ea8105e638429a9B3Ec621d1A7939597",
    signer
  );

  console.log(await aggrWBTC.latestRoundData());

  const iUsdc = await ethers.getContractAt("IFSFI", fsfi, signer);

  const minimal = await iUsdc.checkMinimalCollateralForLoan(
    BigInt(usdcAmount),
    usdc,
    wbtc
  );
  console.log(`Got ${minimal}wBTC`);

  const estimateHeathFactor = await iUsdc.estimateHealthFactor(
    usdc,
    BigInt(1e6),
    wbtc,
    BigInt(3366)
  );
  console.log(`Got ${estimateHeathFactor} health-factor`);
}

describe("sepolia", () => {
  describe("FSFI Pool", () => {
    it.only("approve usdc", async () => {
      const AMOUNT = ethers.parseUnits("600", 6);
      await approveUsdc(AMOUNT);
      await allowanceUsdc();
    });

    it.only("supply", async () => {
      const AMOUNT = ethers.parseUnits("600", 6);
      await supplyUsdc(AMOUNT);
    });
  });

  describe("FSFI Pool usdt", () => {
    it.only("approve usdt", async () => {
      const AMOUNT = ethers.parseUnits("600", 6);
      await approveUsdt(AMOUNT);
      await allowanceUsdt();
    });

    it.only("supply", async () => {
      const AMOUNT = ethers.parseUnits("600", 6);
      await supplyUsdt(AMOUNT);
    });
  });

  describe("FSFI", () => {
    it.only("approve wbtc", async () => {
      const AMOUNT = ethers.parseUnits("0.1", 8);
      await approveWBTC(AMOUNT);
    });

    it.only("create a loan", async () => {
      await createLoan();
    });

    it("create a loan no stake", async () => {
      await createLoanNoStake();
    });

    it("get current loan", async () => {
      getCurrentLoan(BigInt(5));
    });

    it("approve usdc", async () => {
      const AMOUNT = ethers.parseUnits("200", 6);
      await approveLoanUsdc(AMOUNT);
    });

    it("repay loan", async () => {
      repay(BigInt(1), ethers.parseUnits("200", 6));
    });

    it("withdraw collateral", async () => {
      withdrawCollateral(BigInt(1));
    });

    it("check health factor", async () => {
      await getHealthFactor(
        ethers.parseUnits("0.1", 6),
        ethers.parseUnits("0.0005", 8),
        BigInt(1)
      );
    });

    it("liquidate", async () => {
      await liquidate(BigInt(20));
    });

    it("change wbtc price", async () => {
      await changeWbtcprice(60000e8);
      // await changeWbtcprice(10e8);
    });

    it("get minimal wbtc", async () => {
      await getMinimumCollateral(1e6);
    });
  });

  describe("FSFI usdt", () => {
    it.only("approve wbtc", async () => {
      const AMOUNT = ethers.parseUnits("0.1", 8);
      await approveWBTC(AMOUNT);
    });

    it.only("create a loan", async () => {
      await createLoanUSDT();
    });

    it("create a loan no stake", async () => {
      await createLoanNoStake();
    });

    it("get current loan", async () => {
      getCurrentLoan(BigInt(6));
    });

    it("approve usdt", async () => {
      const AMOUNT = ethers.parseUnits("200", 6);
      await approveLoanUsdt(AMOUNT);
    });

    it("repay loan", async () => {
      repayUSDT(BigInt(1), ethers.parseUnits("200", 6));
    });

    it("withdraw collateral", async () => {
      withdrawCollateral(BigInt(1));
    });

    it("check health factor", async () => {
      await getHealthFactor(
        ethers.parseUnits("0.1", 6),
        ethers.parseUnits("0.0005", 8),
        BigInt(2)
      );
    });

    it("liquidate", async () => {
      await liquidate(BigInt(20));
    });

    it("change wbtc price", async () => {
      await changeWbtcprice(60000e8);
      // await changeWbtcprice(10e8);
    });
  });
});
