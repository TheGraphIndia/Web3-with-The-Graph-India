// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EventContract {
    address public owner;
    uint256 public registrationFee;
    
    event Registration(address indexed participant, uint256 registrationId, uint256 timestamp);
    event Cancellation(address indexed participant, uint256 registrationId, uint256 timestamp);
    
    struct RegistrationInfo {
        bool isRegistered;
        uint256 timestamp;
    }
    
    mapping(address => RegistrationInfo) public registrations;
    uint256 public registrationCount;
    
    constructor(uint256 _registrationFee) {
        owner = msg.sender;
        registrationFee = _registrationFee;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }
    
    modifier notRegistered() {
        require(!registrations[msg.sender].isRegistered, "Already registered");
        _;
    }
    
    modifier isRegistered() {
        require(registrations[msg.sender].isRegistered, "Not registered");
        _;
    }
    
    function register() external payable notRegistered {
        require(msg.value == registrationFee, "Incorrect registration fee");
        
        registrations[msg.sender] = RegistrationInfo(true, block.timestamp);
        registrationCount++;
        
        emit Registration(msg.sender, registrationCount, block.timestamp);
    }
    
    function cancelRegistration() external isRegistered {
        delete registrations[msg.sender];
        registrationCount--;
        
        payable(msg.sender).transfer(registrationFee);
        
        emit Cancellation(msg.sender, registrationCount + 1, block.timestamp);
    }
    
    function withdrawFunds() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }
}
