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
   
    mapping (uint256 => string) private tierUri; // (등급업을 위한 충족 횟수 => 충족시 적용되는 URI)
    uint256[100] private requirements; // 현재 등록된 티어 순서 및 충족 횟수

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
    function upgradeRules(SBTInfo calldata _SBTInfo) external onlyOwner {
        require(_SBTInfo.tier < requirements.length,"tier out of range");

        _upgradeRules(_SBTInfo);
    }

    ///@notice 대량의 SBT티어의 등급업 조건, 등급별 URI 수정 함수
    function upgradeBulkRules(SBTInfo[] calldata _SBTInfo) external onlyOwner {
        uint _length = _SBTInfo.length;
        require(_length < requirements.length,"tier out of range");

        for (uint i ; i < _length; i++) 
        {
            _upgradeRules(_SBTInfo[i]);
        }
    }

    ///@notice (Shipper)SBT 티어의 등급업 조건, URI 수정 함수
    ///@dev Rule 업그레이드 하는 로직 중복으로 internal 구현
    ///@dev 티어의 등급업 조건(_requirements)은 낮은 티어 조건보다 크고, 높은 티어보다 낮아야함(단,0티어와 가장 높은 티어 제외)
    function _upgradeRules(SBTInfo calldata _SBTInfo) internal {
        if(_SBTInfo.tier != 0) require(requirements[_SBTInfo.tier-1] < _SBTInfo.requirement,"Must be greater than the requirements of the next lower tier.");
        if(requirements[_SBTInfo.tier+1] != 0) require(requirements[_SBTInfo.tier+1] > _SBTInfo.requirement,"Must be less than the requirements of the next higher tier.");

        requirements[_SBTInfo.tier] = _SBTInfo.requirement;
        tierUri[_SBTInfo.requirement] = _SBTInfo.uri;
    }

    ///@notice 현재 등록된 SBT 모든 티어 등급업 조건 및 해당 URI 조회 함수
    function getRules() public view returns(SBTInfo[] memory) {
        uint _length = requirements.length;
        SBTInfo[] memory results;

        for(uint i = 0; i < _length; i++) {
             results[i] = SBTInfo({
                 tier:i,
                 requirement:requirements[i],
                 uri:tierUri[requirements[i]]
             });

        if(requirements[i+1] == 0) break;
        
        }
         
        return results;
    }


    ///@notice 현재 등록된 SBT 개별 티어의 등급업 조건 및 해당 URI 조회
    function getRuleByTier(uint _tier) public view returns(SBTInfo memory) {
        return SBTInfo({
            tier:_tier,
            requirement:requirements[_tier],
            uri:tierUri[requirements[_tier]]
            });
    }


    ///@notice SBT 민팅 함수(safeMint) || 승급 함수(setURI)
    ///@param _owner : Order Contract의 사용자 지갑주소
    ///@param SBTAddress : Shipper||Carrier SBT Contract 주소
    function checkAvailableSBTs(address _owner,address SBTAddress) external OnlyOrder {
        require(SBTAddress == IOrderRules(OrderRulesCotntract).getShipperSBTAddress() || SBTAddress == IOrderRules(OrderRulesCotntract).getCarrierSBTAddress(), "Only Lodis' SBT address");

        // 최초 민팅시
        if(IERC721(SBTAddress).balanceOf(_owner) == 0) {
            ISBT(SBTAddress).safeMint(_owner,tierUri[requirements[0]]);
            return;
        }

        uint orderCount = IOrder(OrderContract).getRecord(_owner).completeOrder;

        for (uint i=0; i < requirements.length; i++) 
        {
            uint currentStep = requirements[i];
            uint nextStep = requirements[i+1];
            if(currentStep <= orderCount && orderCount < nextStep || nextStep == 0) {
                uint _tokenId = IERC721Enumerable(SBTAddress).tokenOfOwnerByIndex(_owner,0);
                string memory currentTokenUri = IERC721Metadata(SBTAddress).tokenURI(_tokenId);
                string memory upgradeUri = tierUri[currentStep];
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

