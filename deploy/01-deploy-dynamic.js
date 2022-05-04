const { network, ethers } = require("hardhat");
const fs = require("fs");

module.exports = async function (hre) {
  const { getNamedAccounts, deployments } = hre;
  const { deploy, log } = deployments;
  const { deployer } = await getNamedAccounts();
  const chainId = network.config.chainId;

  let ethUsdPriceFeedAddress;
  //Rinkeyby: 0x8A753747A1Fa494EC906cE90E9f37563A8AF630e
  //development: fake address in deploy mocks
  if (chainId == 31337) {
    const ethUsdAgg = await ethers.getContract("MockV3Aggregator");
    ethUsdPriceFeedAddress = ethUsdAgg.address;
  } else {
    ethUsdPriceFeedAddress = "0x8A753747A1Fa494EC906cE90E9f37563A8AF630e";
  }
  //   const highValue = ethers.utils.parseEther("2000");
  const highValue = "200000000";

  const lowSvg = await fs.readFileSync("./img/frown.svg", { encoding: "utf8" });
  const highSvg = await fs.readFileSync("./img/happy.svg", {
    encoding: "utf8",
  });
  args = [highSvg, lowSvg, ethUsdPriceFeedAddress, highValue];

  const dynamicSvgNft = await deploy("DynamicSvgNft", {
    from: deployer,
    args: args,
    logs: true,
  });

  const dynamicContract = await ethers.getContract("DynamicSvgNft");
  await dynamicContract.mintNFT();
  log("NFT Minted!");
};

module.exports.tags = ["all", "dynamicsvg"];
