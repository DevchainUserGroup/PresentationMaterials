pragma solidity ^0.4.18;

contract UserStorage {
    
    mapping(address => bool) addressSet;
    
    mapping(address => bool) accessAllowed;
    
    function UserStorage() public {
        accessAllowed[msg.sender] = true;
    }
    
    modifier platform() {
        require(accessAllowed[msg.sender] == true);
        _;
    }
    
    function allowAccess(address _address) platform public {
        accessAllowed[_address] = true;
    }
    
    function denyAccess(address _address) platform public {
        accessAllowed[_address] = false;
    }
    

    function getAddressSet(address _address) public view returns(bool) {
        return addressSet[_address];
    }
    
    function setAddressSet(address _address, bool _bool) platform public {
        addressSet[_address] = _bool;
    }
    
}

contract UserContract {
    
    UserStorage userStorage;
    
    function UserContract(address _userStorageAddress) public {
        userStorage = UserStorage(_userStorageAddress);
    }
    
    function isMyUserNameRegistered() public view returns(bool) {
        return userStorage.getAddressSet(msg.sender);
    }
    
    function registerMe() public {
        userStorage.setAddressSet(msg.sender, true);
    }

}
