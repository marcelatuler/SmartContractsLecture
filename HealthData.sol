// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
 
/**
* We import the AccessControl contract from OpenZeppelin, 
* which provides a lightweight role-based access system.
* We also import ERC20 for demonstration, though this contract
* does not mint or manage tokens.
*/
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
 
/**
* @title HealthData
* @dev A contract that manages patient health records using role-based access control.
*      - Admins can add nurses, doctors, and set patient data.
*      - Nurses and doctors are assigned roles via the AccessControl library.
*      - Patients have associated health data (bloodPressure, otherExams).
*      - Nurses or doctors need explicit permission to read patient data.
*      - Patients (and admins) can revoke permissions.
*/
contract HealthData is AccessControl {
    // Define role identifiers using keccak256 hashing
    bytes32 public constant NURSE_ROLE = keccak256("NURSE_ROLE");
    bytes32 public constant DOCTOR_ROLE = keccak256("DOCTOR_ROLE");
    bytes32 public constant PATIENT_ROLE = keccak256("PATIENT_ROLE");
 
    /**
     * @dev Patient struct holds bloodPressure (visible by Nurse and Doctor with permission)
     *      and otherExams (visible only by Doctor with permission).
     */
    struct Patient {
        string bloodPressure;
        string otherExams;
    }
 
    // Mapping each patient address to its Patient struct
    mapping(address => Patient) private patients;
    // Mapping patient -> nurse -> permission bool
    mapping(address => mapping(address => bool)) private nursePermissions;
    // Mapping patient -> doctor -> permission bool
    mapping(address => mapping(address => bool)) private doctorPermissions;
 
    /**
     * @dev The constructor grants the deployer the default admin role,
     *      enabling them to assign all other roles.
     */
    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }
 
    /**
     * @notice Adds a nurse to the system.
     * @dev Only an admin (DEFAULT_ADMIN_ROLE) can call this.
     * @param nurse The address to be granted the NURSE_ROLE.
     */
    function addNurse(address nurse) public {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "CALLER_IS_NOT_ADMIN");
        grantRole(NURSE_ROLE, nurse);
    }
 
    /**
     * @notice Adds a doctor to the system.
     * @dev Only an admin (DEFAULT_ADMIN_ROLE) can call this.
     * @param doctor The address to be granted the DOCTOR_ROLE.
     */
    function addDoctor(address doctor) public {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "CALLER_IS_NOT_ADMIN");
        grantRole(DOCTOR_ROLE, doctor);
    }
 
    /**
     * @notice Sets or updates the health data for a patient.
     * @dev Only an admin can call this. Also assigns the PATIENT_ROLE to the given patient.
     * @param patient The address of the patient.
     * @param bloodPressure The patient's blood pressure reading.
     * @param otherExams The patient's other exam data.
     */
    function setPatientData(
        address patient,
        string memory bloodPressure,
        string memory otherExams
    ) public {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "CALLER_IS_NOT_ADMIN");
        patients[patient] = Patient(bloodPressure, otherExams);
        grantRole(PATIENT_ROLE, patient);
    }
 
    /**
     * @notice Grants a nurse permission to access the patient's bloodPressure data.
     * @dev Caller must be an admin; nurse must already have NURSE_ROLE.
     * @param patient The address of the patient whose data is to be accessed.
     * @param nurse The address of the nurse being granted permission.
     */
    function grantNursePermission(address patient, address nurse) public {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "CALLER_IS_NOT_ADMIN");
        require(hasRole(NURSE_ROLE, nurse), "TARGET_IS_NOT_NURSE");
        nursePermissions[patient][nurse] = true;
    }
 
    /**
     * @notice Revokes a nurse's permission to access the patient's bloodPressure data.
     * @dev Caller can be either an admin or the patient; nurse must have NURSE_ROLE.
     * @param patient The address of the patient whose data is protected.
     * @param nurse The address of the nurse whose permission is being revoked.
     */
    function revokeNursePermission(address patient, address nurse) public {
        require(_RevokeControl(msg.sender), "CALLER_CANNOT_REVOKE");
        require(hasRole(NURSE_ROLE, nurse), "TARGET_IS_NOT_NURSE");
        nursePermissions[patient][nurse] = false;
    }
 
    /**
     * @notice Grants a doctor permission to access the patient's full data (bloodPressure and otherExams).
     * @dev Caller must be an admin; doctor must already have DOCTOR_ROLE.
     * @param patient The address of the patient.
     * @param doctor The address of the doctor being granted permission.
     */
    function grantDoctorPermission(address patient, address doctor) public {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "CALLER_IS_NOT_ADMIN");
        require(hasRole(DOCTOR_ROLE, doctor), "TARGET_IS_NOT_DOCTOR");
        doctorPermissions[patient][doctor] = true;
    }
 
    /**
     * @notice Revokes a doctor's permission to access a patient's full data.
     * @dev Caller can be either an admin or the patient; doctor must have DOCTOR_ROLE.
     * @param patient The address of the patient.
     * @param doctor The address of the doctor whose permission is being revoked.
     */
    function revokeDoctorPermission(address patient, address doctor) public {
        require(_RevokeControl(msg.sender), "CALLER_CANNOT_REVOKE");
        require(hasRole(DOCTOR_ROLE, doctor), "TARGET_IS_NOT_DOCTOR");
        doctorPermissions[patient][doctor] = false;
    }
 
    /**
     * @notice Allows a nurse to read the bloodPressure data of a patient if permission has been granted.
     * @param patient The address of the patient.
     * @param nurse The address of the nurse attempting to read the data.
     * @return The patient's bloodPressure string.
     */
    function getBloodPressure(
        address patient,
        address nurse
    ) public view returns (string memory) {
        require(
            nursePermissions[patient][nurse],
            "PERMISSION_DENIED_NURSE"
        );
        return patients[patient].bloodPressure;
    }
 
    /**
     * @notice Allows a doctor to read all the data of a patient (bloodPressure and otherExams) if permission has been granted.
     * @param patient The address of the patient.
     * @param doctor The address of the doctor attempting to read the data.
     * @return bloodPressure and otherExams of the patient.
     */
    function getAllPatientData(
        address patient,
        address doctor
    ) public view returns (string memory, string memory) {
        require(
            doctorPermissions[patient][doctor],
            "PERMISSION_DENIED_DOCTOR"
        );
        Patient memory p = patients[patient];
        return (p.bloodPressure, p.otherExams);
    }
 
    /**
     * @dev Internal function that checks if the caller is an admin or the patient.
     * @param caller The address trying to revoke permissions.
     * @return True if the caller is allowed to revoke, otherwise it reverts.
     */
    function _RevokeControl(address caller) internal view returns (bool) {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, caller) ||
                hasRole(PATIENT_ROLE, caller),
            "CALLER_IS_NOT_ADMIN_OR_PATIENT"
        );
        return true;
    }
}
