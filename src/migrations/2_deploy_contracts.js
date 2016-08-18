module.exports = function(deployer) {
	deployer.deploy(HumanStandardToken, 1000, "Danske Kroner", 2, "DKK").then(function() {
		return deployer.deploy(DMR, HumanStandardToken.address);
	});
};
