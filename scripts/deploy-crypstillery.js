async function main() {
    const Crypstillery = await ethers.getContractFactory("Crypstillery");
    const crypstillery = await Crypstillery.deploy();   
    console.log("Crypstillery Contract deployed to address:", crypstillery.address);
 }
 main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });

// Crypstillery: 