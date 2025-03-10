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

### HealthData: After Writing the Contract
 
Now that you have completed writing your HealthData contract, the next steps involve compiling, deploying, and interacting with your new smart contract in Remix IDE. This guide will walk you through each step, from compilation to running sample transactions.
 
#### Compiling the Contract
1. In Remix, select the Solidity Compiler tab on the left sidebar.
2. From the Compiler dropdown, choose a compatible Solidity version (for example, v0.8.0 if available).
3. Click Compile **HealthData.sol**.
4. If the compilation is successful, you will see a green check mark indicating no errors.
5. Deploying the Contract
6. Go to the Deploy & Run Transactions tab in Remix.
7. In the Environment dropdown, select Remix VM (Cancun) or another suitable test environment.
8. Make sure the Account dropdown is set to the address you want as the admin (the deployer).
9. Click the Deploy button.
10. After deployment, your contract will appear under Deployed Contracts in Remix.

 
### Interacting with the Contract
 
Once your contract is deployed, expand the Deployed Contracts section to reveal its functions. Here are some common interactions:
 
1. Remix provides several pre-generated accounts with addresses and balances. You can find these in the Account dropdown in the Deploy & Run Transactions tab.
2. To use these accounts for different roles (admin, nurse, doctor, patient):
- Select the desired accounts from the Account dropdown.
- Copy the addresses of the selected accounts and save them in a note app, specifying the address and role. (like the example below).
``` Markdown
    Admin: 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
    Doctor1: 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2
    Nurse1: 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db
    Patient: 0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB
```
- Use these addresses in your contract functions to assign roles or interact with the contract.

> **Tip**:  Remix automatically selects the account used for transactions. If you switch to another address to act as a nurse or doctor, remember to switch back to the admin account for admin-only functions.
 
### Add Nurses
 
1. Using **admin** account (the one that deployed the contract).
2. Use `addNurse` to assign the `NURSE_ROLE` to **Nuser1** address from Remix’s pre-generated accounts.
3. In the Deployed Contracts section, find the `addNurse` function.
4. Paste the **Nurse1** address into the `addNurse` input field and click the transact button.
 
### Add Doctor
1. Using **admin** account (the one that deployed the contract).
2. Use `addDoctor` to assign the `DOCTOR_ROLE` to **Doctor1** address.
3. In the Deployed Contracts section, find the `addDoctor` function.
4. Paste the **Doctor1** address into the `addDoctor` input field and click the transact button.
 
### Set Patient Data
 
1. Still with the **admin** account selected, call `setPatientData` to initialize or update a patient’s records.
2. Provide:
- `patientAddress` (Patient1),
- `bloodPressure reading` (e.g., "120/80"),
- `otherExams` (e.g., "otherExams").
3. In the Deployed Contracts section, find the `setPatientData` function.
4. Paste the Patient1 address into the patientAddress input field, enter the blood pressure reading and additional medical exam data, then click the transact button.
 
### grantNursePermission:
1. In the Deployed Contracts section, find the `grantNursePermission` function.
2. Paste the addresses into the respective input fields. Input: `patient1` address, `nurse1` address
3. Click transact button.
4. This nurse can now read the patient’s `bloodPressure` data.
 
 
### grantDoctorPermission:
1. In the Deployed Contracts section, find the `grantDoctorPermission` function.
2. Paste the addresses into the respective input fields. Input: patient1 Address, doctor1 Address
3. Click transact.
4. This doctor can now read the patient’s full record (bloodPressure and otherExams).
 
 
### getBloodPressure (as a nurse):
1. In the Deployed Contracts section, find the `getBloodPressure` function.
2. Past `Patient1` address and nurse1 address that has permission.
3. Click transact.
4. This nurse now have have access to **Patient1** `bloodPressure` data.
 
### getAllPatientData (as a doctor):
1. In the Deployed Contracts section, find the `getAllPatientData` function.
2. Past `Patient1` address and `Doctor1` address that has permission.
3. Click transact
4. Now you can see both `bloodPressure` and `otherExams`.
 
 
### revokeNursePermission:
1. In the Deployed Contracts section, find the revokeNursePermission function.
2. Past `patient1` Address, `nurse1` Address.
3. Click transact to remove the nurse’s permission.
 
### revokeDoctorPermission:
1. In the Deployed Contracts section, find the revokeDoctorPermission function.
2. past `patient` Address, `doctor1` Address.
3. Click transact to remove the doctor’s permission.

---

### Additional Scenarios and Extensions

Your **HealthData** contract is designed to be flexible and can be adapted to a variety of real-world healthcare settings. Consider the following possibilities:

- **Inter-Hospital Data Sharing**: Securely share patient data across multiple healthcare facilities.
- **Family Member Access**: Allow patients to grant read permissions to family members for assistance or oversight.
- **Emergency Access Protocol**: Enable emergency personnel to temporarily access critical patient data under specific conditions.
- **Telemedicine**: Grant remote healthcare providers controlled access to patient records during virtual consultations.
- **Research and Clinical Trials**: Allow authorized researchers to view anonymized patient data for studies, ensuring privacy and compliance.

### Conclusion

By following these steps, you can seamlessly:
1. Compile your **HealthData** contract.
2. Deploy it to a local or test environment in Remix.
3. Manage patient data and permissions (granting, revoking, and accessing data) with ease.

This workflow demonstrates how **role-based access control** can secure critical information in a healthcare context. Experiment with additional features or integrations to match your specific use cases, and enjoy the benefits of secure, transparent data management on the blockchain!

---

### Creating a Function Table for HealthData

When documenting a smart contract (or any piece of code), **function tables** can help readers and exam evaluators quickly understand each function’s purpose, who can call it, what inputs it takes, and what outputs (if any) it returns. Below is a guide on how to fill in such a table, followed by a complete example for the **HealthData** contract.

#### How to Fill the Function Table

1. **Function Name**:  
   - List the exact name of the function in your contract.

2. **Who Can Call (Sender)**:  
   - Identify which user/role is allowed to invoke the function successfully (e.g., Admin, Nurse, Doctor, Patient).  
   - Include any additional conditions (e.g., “must have `DEFAULT_ADMIN_ROLE`”).

3. **Inputs**:  
   - Specify the parameters the function requires.  
   - Note the data types (e.g., `address patient`, `string memory bloodPressure`).

4. **Outputs**:  
   - Indicate whether the function returns any values.  
   - If there are no return values, you can write “None” or “Void.”

5. **Explanation**:  
   - Briefly describe what the function does and why it’s important.  
   - If relevant, mention the `require` conditions.

#### Complete Function Table: HealthData Contract

Below is a table summarizing each external/public function in the **HealthData** contract. Internal or private functions (like `_RevokeControl`) typically don’t appear in this table because they are not meant to be called externally.

| **Function**             | **Who Can Call (Sender)**        | **Inputs**                                                                 | **Outputs**                     | **Explanation**                                                                                                                                                                                            |
|--------------------------|-----------------------------------|----------------------------------------------------------------------------|---------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **addNurse**             | Admin only (`DEFAULT_ADMIN_ROLE`) | `address nurse`                                                            | None                            | Grants the `NURSE_ROLE` to the given `nurse` address. If the caller does not have the admin role, the function reverts with a `require`.                                                                  |
| **addDoctor**            | Admin only (`DEFAULT_ADMIN_ROLE`) | `address doctor`                                                           | None                            | Grants the `DOCTOR_ROLE` to the given `doctor` address. Similar permissions check applies as in `addNurse`.                                                                                               |
| **setPatientData**       | Admin only (`DEFAULT_ADMIN_ROLE`) | `address patient`, `string memory bloodPressure`, `string memory otherExams` | None                            | Allows the admin to set (or update) a patient’s data. Also grants the patient the `PATIENT_ROLE`. If caller is not admin, it reverts.                                                                     |
| **grantNursePermission** | Admin only (`DEFAULT_ADMIN_ROLE`) | `address patient`, `address nurse`                                         | None                            | Lets an admin grant a nurse permission to access the patient’s `bloodPressure`. Requires that `nurse` already has the `NURSE_ROLE`.                                                                       |
| **revokeNursePermission**| Admin or Patient                  | `address patient`, `address nurse`                                         | None                            | Allows an admin **or** the patient to revoke a nurse’s permission. Checks if caller is allowed to revoke via the internal `_RevokeControl` function and if `nurse` is actually a nurse.                   |
| **grantDoctorPermission**| Admin only (`DEFAULT_ADMIN_ROLE`) | `address patient`, `address doctor`                                        | None                            | Lets an admin give a doctor access to both `bloodPressure` and `otherExams` for a patient. Requires that the `doctor` has the `DOCTOR_ROLE`.                                                              |
| **revokeDoctorPermission**| Admin or Patient                 | `address patient`, `address doctor`                                        | None                            | Allows an admin **or** the patient to revoke a doctor’s access to all patient data. Uses `_RevokeControl` internally to ensure the caller is either admin or patient.                                      |
| **getBloodPressure**     | Nurse with permission             | `address patient`, `address nurse`                                         | `string memory` (bloodPressure) | Used by a nurse to read `bloodPressure` data if the nurse has been granted permission in `nursePermissions[patient][nurse]`.                                                                               |
| **getAllPatientData**    | Doctor with permission            | `address patient`, `address doctor`                                        | `(string memory, string memory)` | Returns both `bloodPressure` and `otherExams` if the doctor has permission in `doctorPermissions[patient][doctor]`.                                                                                        |


#### Notes on Internal Functions

- **_RevokeControl**: An internal function used by `revokeNursePermission` and `revokeDoctorPermission`. It checks if the caller is an admin or a patient. Because it’s `internal`, you typically **would not** list it in the table for external documentation. However, in an advanced technical document or developer-facing reference, you might include it separately for completeness.


#### When asked to provide a function table:

1. **Identify** every function you need to document (usually `public` or `external`).
2. **Fill out** the columns (Function, Sender, Inputs, Outputs, Explanation) in a concise manner.
3. **Ensure consistency** with your contract:
   - Verify role requirements match your `require` statements.
   - Double-check input and output data types.
   - Confirm that the explanation matches the function’s logic.

