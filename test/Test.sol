// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract Test {
    uint256 public testvalue;

    function testFunc(uint amount) public returns(uint) {
        testvalue = testvalue + amount;
        return testvalue;
    }

    function testByte(bytes32 _a) public pure returns(bool) {
        // if(_a.length == 0) {
        //     return true;
        // } else {
        //     return false;
        // }
        return _a == 0;
    }

    function getData() public view returns(uint256,uint256) {
        uint256 bgn = gasleft();
        uint256 end = gasleft();
        return (bgn - end,tx.gasprice);
    }
    function testCul(uint256 cost) public pure returns(uint256) {
        return 1e12 * 500 * cost / 1E18;
    }
    function get() pure public returns(uint256) {
        return type(uint256).max;
    }
    function getLength(uint256[] calldata arr) public pure returns(uint) {
        uint8 betLength = uint8(arr.length);
        uint256 totalBetAmount;
        uint256 minBetAmount = 1 ether;
        uint256 maxBetAmount = 22222222222222222222;

        for(uint i = 0; i < betLength;i++) {
            uint _betAmount = arr[i];
            if(_betAmount <= maxBetAmount && _betAmount >= minBetAmount) {
                totalBetAmount += arr[i];
            }
        }
        return betLength;
    }
}
// 6.977900552486188000
// 0xa8694da46a1160f181da73e8b7b3fc57c74ea4a9cf5c2f03edb58c4a244ad90a
// 0x0000000000000000000000000000000000000000000000000000000000000000
// 0.003492912724937999ㅇㅁㅈㅇ