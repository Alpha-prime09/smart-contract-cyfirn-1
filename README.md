# FundMe Smart Contract

[//SPDX-License-Identifier: MIT]

## Overview
`FundMe` is a Solidity smart contract that allows users to fund the contract in ETH (or USDC with price conversion) and allows the owner to withdraw the funds. It enforces a minimum contribution, tracks all funders, and includes gas optimizations to reduce transaction costs.

**Key Features:**
- Users can fund the contract with a minimum amount in USD.
- Owner can withdraw funds efficiently.
- Tracks each funder’s contribution.
- Uses Chainlink price feeds for ETH/USD conversion.
- Gas-optimized with `constant` and `immutable` keywords.

---

## Contract Architecture

### State Variables
- `i_owner` — the owner of the contract (immutable).
- `MINIMUM_USD` — the minimum USD funding requirement (constant).
- `s_funders` — array storing funder addresses.
- `s_addressToAmountFunded` — mapping of addresses to funded amounts.
- `s_priceFeed` — Chainlink price feed interface.

### Constructor
```solidity
constructor(address priceFeedAddress)
