const Migrations = artifacts.require("Migrations");
const Hui = artifacts.require("Hui");

module.exports = function(deployer) {
  deployer.deploy(Migrations);
  deployer.deploy(Hui);
};
