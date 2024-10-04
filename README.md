# Building our own ERC20 Token

## What is an ERC20 Token?

Read further about the ERC20 token [here](https://eips.ethereum.org/EIPS/eip-20).

## Implementing our own ERC20 Token

### Writing the Token Contract

This can be done in two ways:

- Manually implement all the mandatory methods and/or optional methods from the ERC20 interface.
  - This is something we have implemented in the `ManuaslToken.sol`.

- Use inheritance and leverage the existing implementations of the ERC20 token and tweak it as per the requirements.
  - The popular implementations of the ERC20 token are:
    - [Solmate](https://github.com/transmissions11/solmate)
    - [Openzeppelin](https://github.com/OpenZeppelin/openzeppelin-contracts)
  - In our example, we have used `Openzeppelin` and implementation can be found in the `SV15Token.sol`.

Command used to install `openzeppelin library.
  
```shell
forge install OpenZeppelin/openzeppelin-contracts --no-commit
```

### Unit Testing the Contract

In this project, we have leveraged AI - Perplexity to generate the tests for the contracts we have created. The sample query sent to the AI can found in the `Perplexity_Query_Hint.txt`.

### Deploying the Contract

In this project, we are making use of the `Makefile` which can found in the project folder.

Command to start the local anvil instance

```shell
make anvil

# The make anvil command executes the following command
anvil -m 'test test test test test test test test test test test junk' --steps-tracing --block-time 1
```

Command to deploy the contract on the local anvil instance

```shell
make deploy

# The make deploy executes the following command
forge script script/DeploySV15Token.s.sol:DeploySV15Token --rpc-url http://localhost:8545 --private-key $(DEFAULT_ANVIL_KEY)
```
