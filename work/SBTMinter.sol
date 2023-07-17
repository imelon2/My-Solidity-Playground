// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "./interface/IOrderRules.sol";
import "./interface/IOrder.sol";
import "./SBT/interface/ISBT.sol";


contract SBTMinter is Initializable, OwnableUpgradeable, UUPSUpgradeable {

    address private OrderRulesCotntract;
    address private OrderContract;

    mapping (uint256 => string) private ShipperTierUri; // (등급업을 위한 충족 횟수 => 충족시 적용되는 URI)
    uint256[100] private ShipperRequirements; // 현재 등록된 티어 순서 및 충족 횟수
   
    mapping (uint256 => string) private CarrierTierUri; // (등급업을 위한 충족 횟수 => 충족시 적용되는 URI)
    uint256[100] private CarrierRequirements; // 현재 등록된 티어 순서 및 충족 횟수

    struct SBTInfo {
        uint256 tier;
        uint256 requirement;
        string uri;
    }

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    modifier OnlyOrder() {
        require(msg.sender == OrderContract,"Only Order can Call.");
        _;
    }

    function initialize(address _OrderRulesCotntract, address _OrderContract) initializer public {
        __Ownable_init();
        __UUPSUpgradeable_init();

        OrderRulesCotntract = _OrderRulesCotntract;
        OrderContract = _OrderContract;
    }

    

    ///@notice 특정 SBT티어의 등급업 조건, 등급별 URI 수정 함수
    function upgradeShipperRules(SBTInfo calldata _SBTInfo) external onlyOwner {
        require(_SBTInfo.tier < ShipperRequirements.length,"tier out of range");

        _upgradeShipperRules(_SBTInfo);
    }

    ///@notice 대량의 SBT티어의 등급업 조건, 등급별 URI 수정 함수
    function upgradeBulkShipperRules(SBTInfo[] calldata _SBTInfo) external onlyOwner {
        uint _length = _SBTInfo.length;
        require(_length < ShipperRequirements.length,"tier out of range");

        for (uint i ; i < _length; i++) 
        {
            _upgradeShipperRules(_SBTInfo[i]);
        }
    }

    ///@notice (Shipper)SBT 티어의 등급업 조건, URI 수정 함수
    ///@dev Rule 업그레이드 하는 로직 중복으로 internal 구현
    ///@dev 티어의 등급업 조건(_requirements)은 낮은 티어 조건보다 크고, 높은 티어보다 낮아야함(단,0티어와 가장 높은 티어 제외)
    function _upgradeShipperRules(SBTInfo calldata _SBTInfo) internal {
        require(_SBTInfo.requirement != 0,"The requirement must be greater than 0");
        if(_SBTInfo.tier != 0) require(ShipperRequirements[_SBTInfo.tier-1] < _SBTInfo.requirement,"Must be greater than the requirements of the next lower tier.");
        if(ShipperRequirements[_SBTInfo.tier+1] != 0) require(ShipperRequirements[_SBTInfo.tier+1] > _SBTInfo.requirement,"Must be less than the requirements of the next higher tier.");

        ShipperRequirements[_SBTInfo.tier] = _SBTInfo.requirement;
        ShipperTierUri[_SBTInfo.requirement] = _SBTInfo.uri;
    }

    ///@notice 특정 SBT티어의 등급업 조건, 등급별 URI 수정 함수
    function upgradeCarrierRules(SBTInfo calldata _SBTInfo) external onlyOwner {
        require(_SBTInfo.tier < CarrierRequirements.length,"tier out of range");

        _upgradeCarrierRules(_SBTInfo);
    }

    ///@notice 대량의 SBT티어의 등급업 조건, 등급별 URI 수정 함수
    function upgradeBulkCarrierRules(SBTInfo[] calldata _SBTInfo) external onlyOwner {
        uint _length = _SBTInfo.length;
        require(_length < CarrierRequirements.length,"tier out of range");

        for (uint i ; i < _length; i++) 
        {
            _upgradeCarrierRules(_SBTInfo[i]);
        }
    }

    ///@notice (Shipper)SBT 티어의 등급업 조건, URI 수정 함수
    ///@dev Rule 업그레이드 하는 로직 중복으로 internal 구현
    ///@dev 티어의 등급업 조건(_requirements)은 낮은 티어 조건보다 크고, 높은 티어보다 낮아야함(단,0티어와 가장 높은 티어 제외)
    function _upgradeCarrierRules(SBTInfo calldata _SBTInfo) internal {
        require(_SBTInfo.requirement != 0,"The requirement must be greater than 0");
        if(_SBTInfo.tier != 0) require(CarrierRequirements[_SBTInfo.tier-1] < _SBTInfo.requirement,"Must be greater than the requirements of the next lower tier.");
        if(CarrierRequirements[_SBTInfo.tier+1] != 0) require(CarrierRequirements[_SBTInfo.tier+1] > _SBTInfo.requirement,"Must be less than the requirements of the next higher tier.");

        CarrierRequirements[_SBTInfo.tier] = _SBTInfo.requirement;
        CarrierTierUri[_SBTInfo.requirement] = _SBTInfo.uri;
    }

    ///@notice 현재 등록된 SBT 모든 티어 등급업 조건 및 해당 URI 조회 함수
    function getShipperRules() public view returns(SBTInfo[] memory) {
        uint _length = ShipperRequirements.length;
        SBTInfo[] memory results = new SBTInfo[](_length);


        for(uint i = 0; i < _length; i++) {
             results[i] = SBTInfo({
                 tier:i,
                 requirement:ShipperRequirements[i],
                 uri:ShipperTierUri[ShipperRequirements[i]]
             });
         }

        return results;
    }


    ///@notice 현재 등록된 SBT 개별 티어의 등급업 조건 및 해당 URI 조회
    function getShipperRuleByTier(uint _tier) public view returns(SBTInfo memory) {
        return SBTInfo({
            tier:_tier,
            requirement:ShipperRequirements[_tier],
            uri:ShipperTierUri[ShipperRequirements[_tier]]
            });
    }


    ///@notice 현재 등록된 SBT 모든 티어 등급업 조건 및 해당 URI 조회 함수
    function getCarrierRules() public view returns(SBTInfo[] memory) {
        uint _length = CarrierRequirements.length;
        SBTInfo[] memory results = new SBTInfo[](_length);


        for(uint i = 0; i < _length; i++) {
             results[i] = SBTInfo({
                 tier:i,
                 requirement:CarrierRequirements[i],
                 uri:CarrierTierUri[CarrierRequirements[i]]
             });
         }

        return results;
    }


    ///@notice 현재 등록된 SBT 개별 티어의 등급업 조건 및 해당 URI 조회
    function getCarrierRuleByTier(uint _tier) public view returns(SBTInfo memory) {
        return SBTInfo({
            tier:_tier,
            requirement:CarrierRequirements[_tier],
            uri:CarrierTierUri[CarrierRequirements[_tier]]
            });
    }


    ///@notice SBT 민팅 함수(safeMint) || 승급 함수(setURI)
    ///@param _owner : Order Contract의 사용자 지갑주소
    ///@param SBTAddress : Shipper||Carrier SBT Contract 주소
    function checkAvailableSBTs(address _owner,address SBTAddress) external OnlyOrder {
        if(SBTAddress == IOrderRules(OrderRulesCotntract).getShipperSBTAddress()) {
            setShipperSBT(_owner,SBTAddress);
        } else if (SBTAddress == IOrderRules(OrderRulesCotntract).getCarrierSBTAddress()) {
            setCarrierSBT(_owner,SBTAddress);
        } else {
            revert("Only Lodis' SBT address");
        }
    }

    function setShipperSBT(address _owner, address SBTAddress) private {

        // 최초 민팅시
        if(IERC721(SBTAddress).balanceOf(_owner) == 0) {
            ISBT(SBTAddress).safeMint(_owner,ShipperTierUri[ShipperRequirements[0]]);
            return;
        }

        uint orderCount = IOrder(OrderContract).getRecord(_owner).completeOrder_shipping;
        for (uint i=0; i < ShipperRequirements.length; i++) 
        {
            uint currentStep = ShipperRequirements[i];
            uint nextStep = ShipperRequirements[i+1];
            if(currentStep <= orderCount && orderCount < nextStep || nextStep == 0) {
                uint _tokenId = IERC721Enumerable(SBTAddress).tokenOfOwnerByIndex(_owner,0);
                string memory currentTokenUri = IERC721Metadata(SBTAddress).tokenURI(_tokenId);
                string memory upgradeUri = ShipperTierUri[currentStep];
                if(keccak256(abi.encodePacked(currentTokenUri)) == keccak256(abi.encodePacked(upgradeUri))) {
                    break;
                }
                ISBT(SBTAddress).setTokenURI(_tokenId,upgradeUri);
                break ;
            } 
        }
    }

    function setCarrierSBT(address _owner, address SBTAddress) private {
        // 최초 민팅시
        if(IERC721(SBTAddress).balanceOf(_owner) == 0) {
            ISBT(SBTAddress).safeMint(_owner,CarrierTierUri[CarrierRequirements[0]]);
            return;
        }
        
        uint orderCount = IOrder(OrderContract).getRecord(_owner).completeOrder_carrying;
        for (uint i=0; i < CarrierRequirements.length; i++) 
        {
            uint currentStep = CarrierRequirements[i];
            uint nextStep = CarrierRequirements[i+1];
            if(currentStep <= orderCount && orderCount < nextStep || nextStep == 0) {
                uint _tokenId = IERC721Enumerable(SBTAddress).tokenOfOwnerByIndex(_owner,0);
                string memory currentTokenUri = IERC721Metadata(SBTAddress).tokenURI(_tokenId);
                string memory upgradeUri = CarrierTierUri[currentStep];
                if(keccak256(abi.encodePacked(currentTokenUri)) == keccak256(abi.encodePacked(upgradeUri))) {
                    break;
                }
                ISBT(SBTAddress).setTokenURI(_tokenId,upgradeUri);
                break ;
            } 
        }
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        onlyOwner
        override
    {}
}

