// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract testArray {
    uint256[100] public ShipperRequirements;

    function upgrade(uint256[] calldata _data) external {
        uint256 _length = _data.length;
        
        for (uint i ; i < _length; i++) 
        {
            ShipperRequirements[i] = _data[i];
        }
    }

        function getShipperRules() public view returns(uint256[] memory) {
        uint _length = ShipperRequirements.length;
        uint256[] memory results = new uint256[](_length);


        for(uint i = 0; i < _length; i++) {
             results[i] = SBTInfo({
                 tier:i,
                 requirement:ShipperRequirements[i],
                 uri:ShipperTierUri[ShipperRequirements[i]]
             });
         }

        return results;
    }
}