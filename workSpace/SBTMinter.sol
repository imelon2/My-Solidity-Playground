// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "./interface/IOrderRules.sol";

// SBTMintChecker -> SBTMinter
contract SBTMinter is Initializable, OwnableUpgradeable, UUPSUpgradeable {

    
    address private OrderRulesCotntract;
    address private SBTContract;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    // function initialize(address _OrderContract,address _SBTContract) initializer public {
    //     __Ownable_init();
    //     __UUPSUpgradeable_init();


    //     OrderContract = _OrderContract;
    //     SBTContract = _SBTContract;
    // }
    function initialize(address _OrderRulesCotntract,address _SBTContract) initializer public {
        __Ownable_init();
        __UUPSUpgradeable_init();

        OrderRulesCotntract = _OrderRulesCotntract;
        SBTContract = _SBTContract;
    }

    function addRules() external {}

    function removeRules() external {}
    
    function checkAvailableSBTs(address _a) external returns(bool) {
        // IERC721(SBTContract).balanceOf(_a);
        //OrderContract.getCompleteOrderCount();

    }

    function _authorizeUpgrade(address newImplementation)
        internal
        onlyOwner
        override
    {}
}