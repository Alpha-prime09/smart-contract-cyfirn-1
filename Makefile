-include .env

build:; forge build

deploy-sepolia:
	 forge script script/DeployFundme.s.sol --rpc-url $(SEPOLIA_RPC_URL) --account sepoliaMetamask --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv
