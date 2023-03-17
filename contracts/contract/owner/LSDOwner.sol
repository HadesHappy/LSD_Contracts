// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";

import "../LSDBase.sol";
import "../../interface/owner/ILSDOwner.sol";
import "../../interface/ILSDStorage.sol";

contract LSDOwner is Ownable, LSDBase, ILSDOwner {
    // Events
    event ContractUpgraded(
        bytes32 indexed name,
        address indexed oldAddress,
        address indexed newAddress,
        uint256 time
    );
    event ContractAdded(
        bytes32 indexed name,
        address indexed newAddress,
        uint256 time
    );
    event ABIUpgraded(bytes32 indexed name, uint256 time);
    event ABIAdded(bytes32 indexed name, uint256 time);

    // The namespace for any data in the owner setting
    string private constant ownerSettingNameSpace = "owner.setting";

    // Construct
    constructor(ILSDStorage _lsdStorageAddress) LSDBase(_lsdStorageAddress) {
        // Version
        version = 1;
    }

    // Get the annual profit
    function getApy() public view override returns (uint256) {
        return
            getUint(keccak256(abi.encodePacked(ownerSettingNameSpace, "apy")));
    }

    // Get the staking annual profit
    function getStakeApr() public view override returns (uint256) {
        return
            getUint(keccak256(abi.encodePacked(ownerSettingNameSpace, "stake.apr")));
    }

    // Get the LIDO Apy
    function getLIDOApy() public view override returns (uint256) {
        return
            getUint(
                keccak256(abi.encodePacked(ownerSettingNameSpace, "lido.apy"))
            );
    }

    // Get the RP Apy
    function getRPApy() public view override returns (uint256) {
        return
            getUint(
                keccak256(abi.encodePacked(ownerSettingNameSpace, "rp.apy"))
            );
    }

    // Get the SWISE Apy
    function getSWISEApy() public view override returns (uint256) {
        return
            getUint(
                keccak256(abi.encodePacked(ownerSettingNameSpace, "swise.apy"))
            );
    }

    // Get the protocol fee
    function getProtocolFee() public view override returns (uint256) {
        return
            getUint(
                keccak256(
                    abi.encodePacked(ownerSettingNameSpace, "protocol.fee")
                )
            );
    }

    // Get the multiplier
    function getMultiplier() public view override returns (uint256) {
        return
            getUint(
                keccak256(abi.encodePacked(ownerSettingNameSpace, "multiplier"))
            );
    }

    // Get the minimum deposit amount
    function getMinimumDepositAmount() public view override returns (uint256) {
        return
            getUint(
                keccak256(
                    abi.encodePacked(
                        ownerSettingNameSpace,
                        "minimum.deposit.amount"
                    )
                )
            );
    }

    // Set the annual profit
    function setApy(uint256 _apy) public override onlyOwner {
        setUint(
            keccak256(abi.encodePacked(ownerSettingNameSpace, "apy")),
            _apy
        );
    }

    // Set the staking annual profit
    function setStakeApr(uint256 _stakeApr) public override onlyOwner {
        setUint(
            keccak256(abi.encodePacked(ownerSettingNameSpace, "stake.apr")),
            _stakeApr
        );
    }

    // Set the protocol fee
    function setProtocolFee(uint256 _protocalFee) public override onlyOwner {
        setUint(
            keccak256(abi.encodePacked(ownerSettingNameSpace, "protocol.fee")),
            _protocalFee
        );
    }

    // Set the minimum deposit amount
    function setMinimumDepositAmount(
        uint256 _minimumDepositAmount
    ) public override onlyOwner {
        setUint(
            keccak256(
                abi.encodePacked(
                    ownerSettingNameSpace,
                    "minimum.deposit.amount"
                )
            ),
            _minimumDepositAmount
        );
    }

    // Set the multiplier
    function setMultiplier(uint256 _multiplier) public override onlyOwner {
        setUint(
            keccak256(abi.encodePacked(ownerSettingNameSpace, "multiplier")),
            _multiplier
        );
    }

    // Set the LIDO Apy
    function setLIDOApy(uint256 _lidoApy) public override onlyOwner {
        setUint(
            keccak256(abi.encodePacked(ownerSettingNameSpace, "lido.apy")),
            _lidoApy
        );
    }

    // Set the RP Apy
    function setRPApy(uint256 _rpApy) public override onlyOwner {
        setUint(
            keccak256(abi.encodePacked(ownerSettingNameSpace, "rp.apy")),
            _rpApy
        );
    }

    // Set the SWISE Apy
    function setSWISEApy(uint256 _swiseApy) public override onlyOwner {
        setUint(
            keccak256(abi.encodePacked(ownerSettingNameSpace, "swise.apy")),
            _swiseApy
        );
    }

    // Main accessor for performing an upgrade, be it a contract or abi for a contract
    function upgrade(
        string memory _type,
        string memory _name,
        string memory _contractAbi,
        address _contractAddress
    ) external override onlyOwner {
        // What action are we performing?
        bytes32 typeHash = keccak256(abi.encodePacked(_type));
        // Lets do it!
        if (typeHash == keccak256(abi.encodePacked("upgradeContract")))
            _upgradeContract(_name, _contractAddress, _contractAbi);
        if (typeHash == keccak256(abi.encodePacked("addContract")))
            _addContract(_name, _contractAddress, _contractAbi);
        if (typeHash == keccak256(abi.encodePacked("upgradeABI")))
            _upgradeABI(_name, _contractAbi);
        if (typeHash == keccak256(abi.encodePacked("addABI")))
            _addABI(_name, _contractAbi);
    }

    /*** Internal Upgrade Methods for the Owner ****************/
    // Add a new network contract
    function _addContract(
        string memory _name,
        address _contractAddress,
        string memory _contractAbi
    ) internal {
        // Check contract name
        bytes32 nameHash = keccak256(abi.encodePacked(_name));
        require(bytes(_name).length > 0, "Invalid contract name");
        // Cannot add contract if it already exists (use upgradeContract instead)
        require(
            getAddress(
                keccak256(abi.encodePacked("contract.address", _name))
            ) == address(0x0),
            "Contract name is already in use"
        );
        // Cannot add contract if already in use as ABI only
        string memory existingAbi = getString(
            keccak256(abi.encodePacked("contract.abi", _name))
        );
        require(
            bytes(existingAbi).length == 0,
            "Contract name is already in use"
        );
        // Check contract address
        require(_contractAddress != address(0x0), "Invalid contract address");
        require(
            !getBool(
                keccak256(abi.encodePacked("contract.exists", _contractAddress))
            ),
            "Contract address is already in use"
        );
        // Check ABI isn't empty
        require(bytes(_contractAbi).length > 0, "Empty ABI is invalid");
        // Register contract
        setBool(
            keccak256(abi.encodePacked("contract.exists", _contractAddress)),
            true
        );
        setString(
            keccak256(abi.encodePacked("contract.name", _contractAddress)),
            _name
        );
        setAddress(
            keccak256(abi.encodePacked("contract.address", _name)),
            _contractAddress
        );
        setString(
            keccak256(abi.encodePacked("contract.abi", _name)),
            _contractAbi
        );
        // Emit contract added event
        emit ContractAdded(nameHash, _contractAddress, block.timestamp);
    }

    // Add a new network contract ABI
    function _addABI(string memory _name, string memory _contractAbi) internal {
        // Check ABI name
        bytes32 nameHash = keccak256(abi.encodePacked(_name));
        require(bytes(_name).length > 0, "Invalid ABI name");
        // Sanity check
        require(bytes(_contractAbi).length > 0, "Empty ABI is invalid");
        // Cannot add ABI if name is already used for an existing network contract
        require(
            getAddress(
                keccak256(abi.encodePacked("contract.address", _name))
            ) == address(0x0),
            "ABI name is already in use"
        );
        // Cannot add ABI if ABI already exists for this name (use upgradeABI instead)
        string memory existingAbi = getString(
            keccak256(abi.encodePacked("contract.abi", _name))
        );
        require(bytes(existingAbi).length == 0, "ABI name is already in use");
        // Set ABI
        setString(
            keccak256(abi.encodePacked("contract.abi", _name)),
            _contractAbi
        );
        // Emit ABI added event
        emit ABIAdded(nameHash, block.timestamp);
    }

    // Upgrade a network contract ABI
    function _upgradeABI(
        string memory _name,
        string memory _contractAbi
    ) internal {
        // Check ABI exists
        string memory existingAbi = getString(
            keccak256(abi.encodePacked("contract.abi", _name))
        );
        require(bytes(existingAbi).length > 0, "ABI does not exist");
        // Sanity checks
        require(bytes(_contractAbi).length > 0, "Empty ABI is invalid");
        require(
            keccak256(bytes(existingAbi)) != keccak256(bytes(_contractAbi)),
            "ABIs are identical"
        );
        // Set ABI
        setString(
            keccak256(abi.encodePacked("contract.abi", _name)),
            _contractAbi
        );
        // Emit ABI upgraded event
        emit ABIUpgraded(keccak256(abi.encodePacked(_name)), block.timestamp);
    }

    // Upgrade a network contract
    function _upgradeContract(
        string memory _name,
        address _contractAddress,
        string memory _contractAbi
    ) internal {
        bytes32 nameHash = keccak256(abi.encodePacked(_name));
        // Get old contract address & check contract exists
        address oldContractAddress = getAddress(
            keccak256(abi.encodePacked("contract.address", _name))
        );
        require(oldContractAddress != address(0x0), "Contract does not exist");
        // Check new contract address
        require(_contractAddress != address(0x0), "Invalid contract address");
        require(
            _contractAddress != oldContractAddress,
            "The contract address cannot be set to its current address"
        );
        require(
            !getBool(
                keccak256(abi.encodePacked("contract.exists", _contractAddress))
            ),
            "Contract address is already in use"
        );
        // Check ABI isn't empty
        require(bytes(_contractAbi).length > 0, "Empty ABI is invalid");
        // Register new contract
        setBool(
            keccak256(abi.encodePacked("contract.exists", _contractAddress)),
            true
        );
        setString(
            keccak256(abi.encodePacked("contract.name", _contractAddress)),
            _name
        );
        setAddress(
            keccak256(abi.encodePacked("contract.address", _name)),
            _contractAddress
        );
        setString(
            keccak256(abi.encodePacked("contract.abi", _name)),
            _contractAbi
        );
        // Deregister old contract
        deleteString(
            keccak256(abi.encodePacked("contract.name", oldContractAddress))
        );
        deleteBool(
            keccak256(abi.encodePacked("contract.exists", oldContractAddress))
        );
        // Emit contract upgraded event
        emit ContractUpgraded(
            nameHash,
            oldContractAddress,
            _contractAddress,
            block.timestamp
        );
    }
}
