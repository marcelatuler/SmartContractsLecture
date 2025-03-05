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
pragma solidity ^0.8.0;
```
This tells the Solidity compiler which version of the language we’re using. Here, ^0.8.0 means any compiler version from 0.8.0 up to (but not including) the next major version (i.e., 0.9.0).

###### Line 3 

```solidity 
import "@openzeppelin/contracts/access/AccessControl.sol";
```
We import the AccessControl contract from OpenZeppelin. This library provides role-based access control mechanisms that we will use to manage permissions (Admin, Nurse, Doctor, Patient).

###### Line 4

```solidity 
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
```
Although this contract does not specifically create or handle ERC20 tokens, we include the import for demonstration purposes—perhaps you want to extend functionalities or track tokens in the future.

(If you’re only focusing on role-based access, you don’t strictly need ERC20. But for this tutorial, we keep it to show how multiple libraries can be imported.)

###### Lines 5–6: Contract Declaration
```solidity 
contract HealthData is AccessControl {
```
We declare a new contract named **HealthData**, which inherits from **AccessControl**. This inheritance gives us access to the role-based control functions and state variables (e.g., `grantRole`, `hasRole`, etc.).

###### Lines 7–9: Role Constants
```solidity
    bytes32 public constant NURSE_ROLE = keccak256("NURSE_ROLE"); 
    bytes32 public constant DOCTOR_ROLE = keccak256("DOCTOR_ROLE"); 
    bytes32 public constant PATIENT_ROLE = keccak256("PATIENT_ROLE");
```
- We define three role identifiers—NURSE_ROLE, DOCTOR_ROLE, and PATIENT_ROLE—using the `keccak256` hashing function.
- Each role is a `bytes32` constant and will be used to check and grant permissions throughout the contract.

###### Lines 10–13: Patient Struct
```solidity
    struct Patient {
        string bloodPressure; // Nurse and Doctor can have access.
        string otherExams;    // Only Doctor can have access.
    }
```
- The Patient struct holds two pieces of data: `bloodPressure` and `otherExams`.
- In our contract, `bloodPressure` can be accessed by Nurses and Doctors (with permission), while `otherExams` is only accessible to Doctors (with permission).

###### Lines 14–16: Mappings

```solidity
    mapping(address => Patient) private patients;
    mapping(address => mapping(address => bool)) private nursePermissions;
    mapping(address => mapping(address => bool)) private doctorPermissions;
```
- **patients:** Maps each patient’s address to a `Patient` struct.
- **nursePermissions:** For a given patient address, maps each nurse address to a boolean indicating whether the nurse can see that patient’s blood pressure.
- **doctorPermissions:** For a given `patient` address, maps each `doctor` address to a boolean indicating whether the doctor can see the patient’s full data (`bloodPressure` and `otherExams`).

###### Lines 17–20: Constructor
```solidity
    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);  
    }
```
- The constructor is called once when the contract is deployed.
- `_grantRole(DEFAULT_ADMIN_ROLE, msg.sender)` grants the deployer of the contract the **admin role**, which allows them to set up the rest of the system (adding nurses, doctors, setting patient data, etc.).

#### Understanding `require` and its parameters
In Solidity, `require` statements serve as checks that must be satisfied for a transaction (function call) to proceed. If the condition in `require` is not met, the transaction is **reverted** (undone), and the provided message string is returned to the caller, indicating the reason for the failure. 

###### Lines 21–25: addNurse Function

```solidity
    function addNurse(address nurse) public {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "CALLER_IS_NOT_ADMIN");
        grantRole(NURSE_ROLE, nurse);
    }
```
- This function grants the `NURSE_ROLE` to the address specified in the `nurse` parameter.
- Uses `require` to ensure only addresses with the **DEFAULT_ADMIN_ROLE** can call this function; otherwise, it reverts with the message `"CALLER_IS_NOT_ADMIN"`.
- 
###### Lines 26–30: addDoctor Function

```solidity  
    function addDoctor(address doctor) public {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "CALLER_IS_NOT_ADMIN");
        grantRole(DOCTOR_ROLE, doctor);
    }
```
- Similar to **addNurse**, but for granting the `DOCTOR_ROLE`.
- Only an admin can call this function; if not, `"CALLER_IS_NOT_ADMIN"` is thrown.

###### Lines 31–36: setPatientData Function

```solidity  
    function setPatientData(address patient, string memory bloodPressure, string memory otherExams) public {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "CALLER_IS_NOT_ADMIN");
        patients[patient] = Patient(bloodPressure, otherExams);
        grantRole(PATIENT_ROLE, patient);
    }
```
- An admin can set or update a patient’s data by providing patient, bloodPressure, and otherExams.
- Grants the `PATIENT_ROLE` to the patient.
If the caller does not have the DEFAULT_ADMIN_ROLE, the transaction is reverted with "CALLER_IS_NOT_ADMIN".

###### Lines 37–43: grantNursePermission Function

```solidity      
    function grantNursePermission(address patient, address nurse) public {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "CALLER_IS_NOT_ADMIN");
        require(hasRole(NURSE_ROLE, nurse), "TARGET_IS_NOT_NURSE");
        nursePermissions[patient][nurse] = true;
    }
```
- Allows an **admin** to give a nurse permission to view a patient’s `bloodPressure`.
- Checks that the caller is an admin, otherwise (CALLER_IS_NOT_ADMIN)
- Checks that the nurse already has the **NURSE_ROLE**, otherwise `TARGET_IS_NOT_NURSE`.

###### Lines 44–49: revokeNursePermission Function
```solidity   
    function revokeNursePermission(address patient, address nurse) public {
        require(_RevokeControl(msg.sender), "CALLER_CANNOT_REVOKE");
        require(hasRole(NURSE_ROLE, nurse), "TARGET_IS_NOT_NURSE");
        nursePermissions[patient][nurse] = false;
    }
```
- Either an **admin** or the **patient** can call this function to remove the nurse’s access.
- `_RevokeControl` ensures the caller is authorized; otherwise, `"CALLER_CANNOT_REVOKE"` is returned.
- Also checks `TARGET_IS_NOT_NURSE` to ensure that the address in question actually holds the `NURSE_ROLE`.

###### Lines 50–55: grantDoctorPermission Function
```solidity   
    function grantDoctorPermission(address patient, address doctor) public {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "CALLER_IS_NOT_ADMIN");
        require(hasRole(DOCTOR_ROLE, doctor), "TARGET_IS_NOT_DOCTOR");
        doctorPermissions[patient][doctor] = true;
    }
```
- Allows an admin to grant a `doctor` permission to view a patient’s `bloodPressure` and `otherExams`.
- Requires that the caller is an **admin** and that doctor holds the `DOCTOR_ROLE`; otherwise, the transaction fails.

###### Lines 56–61: revokeDoctorPermission Function
```solidity   
    function revokeDoctorPermission(address patient, address doctor) public {
        require(_RevokeControl(msg.sender), "CALLER_CANNOT_REVOKE");
        require(hasRole(DOCTOR_ROLE, doctor), "TARGET_IS_NOT_DOCTOR");
        doctorPermissions[patient][doctor] = false;
    }
```
- Removes a doctor’s access to patient data.
- Ensures (via `_RevokeControl`) that only an **admin** or the **patient** can perform the revocation.
- Also checks that the `doctor` address actually holds the `DOCTOR_ROLE`.

###### Lines 62–66: getBloodPressure Function
```solidity      
    function getBloodPressure(address patient, address nurse) public view returns (string memory) {
        require(nursePermissions[patient][nurse], "PERMISSION_DENIED_NURSE");
        return patients[patient].bloodPressure;
    }
```
- Allows a nurse to retrieve the patient’s `bloodPressure` if they have been granted permission.
- If `nursePermissions[patient][nurse]` is false, the transaction is reverted with `"PERMISSION_DENIED_NURSE"`.

###### Lines 67–72: getAllPatientData Function
```solidity      
   function getAllPatientData(address patient, address doctor) public view returns (string memory, string memory) {
        require(doctorPermissions[patient][doctor], "PERMISSION_DENIED_DOCTOR");
        Patient memory p = patients[patient];
        return (p.bloodPressure, p.otherExams);
    }
```
- Allows a doctor to view both `bloodPressure` and `otherExams` if permission is granted.
- If `doctorPermissions[patient][doctor]` is false, it reverts with `"PERMISSION_DENIED_DOCTOR"`.

###### Lines 73–78: _RevokeControl Function (Internal)
```solidity   
    function _RevokeControl(address caller) internal view returns (bool){
        require(
            hasRole(DEFAULT_ADMIN_ROLE, caller) || hasRole(PATIENT_ROLE, caller),
            "CALLER_IS_NOT_ADMIN_OR_PATIENT"
        );
        return true;
    }
}
```

- Internal function that checks whether the `caller` is an admin or a patient.
- Reverts with `"CALLER_IS_NOT_ADMIN_OR_PATIENT"` if the condition fails.
Used by **revoke** functions to ensure only authorized entities can remove permissions.


#### Congratulations! You have now completed writing the HealthData contract line by line.


