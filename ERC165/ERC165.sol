pragma solidity ^0.8.10;

interface Solidity101 {
    function hello() external;
    // function world(int) external pure;
}

interface IERC165 {
        function supportsInterface(bytes4 interfaceId) external  view returns (bool);
}
contract Selector is IERC165 {

    bytes4 public _interfaceIf = this.supportsInterface.selector;

    function supportsInterface(bytes4 interfaceId) public pure override returns (bool) {
        return 
        interfaceId == type(IERC165).interfaceId ||
        interfaceId == type(Solidity101).interfaceId;
    }

    // function calculateSelector() public pure returns (bytes4) {
    //     Solidity101 i;
    //     return i.hello.selector ^ i.world.selector;
    // }
    function calculateSelector1() public pure returns (bytes4) {
        Solidity101 i;
        return i.hello.selector;
    }
    // function calculateSelector2() public pure returns (bytes4) {
    //     Solidity101 i;
    //     return  i.world.selector;
    // }
    function calculateSelector3() public pure returns (bytes4) {
        // Solidity101 i;
        return  bytes4(keccak256("function hello()"));
    }
}