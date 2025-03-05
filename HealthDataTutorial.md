#### Tutorial Class: Deploying and Interacting with the HealthData Smart Contract in Remix IDE

#### Class Objective
Students will learn how to deploy and interact with a Solidity smart contract using the **Remix IDE**. We will focus on the **HealthData** contract, which leverages role-based access control to manage patient data securely and efficiently.

#### Tools Needed
- A web browser with access to [Remix IDE](https://remix.ethereum.org/).

#### Setting Up the Development Environment

#### 1. Navigate to Remix IDE
1. Open your web browser and go to [https://remix.ethereum.org](https://remix.ethereum.org).
2. Familiarize yourself with the **Remix** interface, which includes:
   - **File Explorer** (where you create and manage Solidity files)
   - **Code Editor** (where you write your smart contract code)
   - **Solidity Compiler** tab
   - **Deploy & Run Transactions** tab

#### 2. Creating a New File
1. In the **File Explorer**, create a new file and name it `HealthData.sol`.
2. We will now build our contract **line by line**. Copy and paste each snippet into your new file in sequence, **then read the explanation** to understand what each line does.

#### Writing the HealthData Contract (Line by Line)

###### Line 1

```solidity
// SPDX-License-Identifier: MIT
```
This line declares the software license under which you are distributing your code. It’s considered best practice (and sometimes a requirement) to specify a license identifier. Here, we’re using the MIT license.

###### Line 2

```solidity
// pragma solidity ^0.8.0;
```
This tells the Solidity compiler which version of the language we’re using. Here, ^0.8.0 means any compiler version from 0.8.0 up to (but not including) the next major version (i.e., 0.9.0).


