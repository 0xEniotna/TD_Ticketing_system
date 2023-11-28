# Test Driven Programming

The goal of this TD is to understand the concept of test driven development. Write tests first, contracts after.

You are going to build a decentralized ticketing system.
Artists, Venues and users can interact with each others to create, sell, transfer tickets/concerts.

Simply run `forge test` (or `forge test --via-ir` if there is a gas issue). All the tests must be green.

You can run a unique file by adding the `--match-path test/x.t.sol` parameter.
`forge test --via-ir --match-path test/6_ticketSelling.sol`

Your contract file must be called `ticketingSystem.sol`, the contract name must be `TicketingSystem`.

## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

- **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
- **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
- **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
- **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
