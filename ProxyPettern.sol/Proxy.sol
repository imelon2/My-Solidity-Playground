// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

// import "@openzeppelin/contracts/utils/StorageSlot.sol";
// import "@openzeppelin/contracts/utils/Address.sol";
// import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Upgrade.sol";


contract CodeV1 {
    address public implementation;
    address public admin;
    uint public count;

    function inc() external {
        count += 1;
    }
}

contract CodeV2 {
    address public implementation;
    address public admin;
    uint public count;

    function inc() external {
        count += 1;
    }

    function dec() external {
        count -= 1;
    }
}

contract BuggyProxy {
    address public implementation;
    address public admin;

    constructor() {
        admin = msg.sender;
    }

    function _delegate() private {
        (bool ok,) = implementation.delegatecall(msg.data);
        require(ok,"delegatecall failed");
    }
    // function _delegate(address _implementation) private {
    //     assembly {
    //         // Copy msg.data. We take full control of memory in this inline assembly
    //         // block because it will not return to Solidity code. We overwrite the
    //         // Solidity scratch pad at memory position 0.

    //         // calldatacopy(t, f, s)
    //         // - copy s bytes from calldata at position f to mem at position t
    //         // calldatasize() - size of call data in bytes

    //         // CALLDATASIZE: msg.data의 길이를 반환합니다. 이 때 단위는 “바이트" 입니다.
    //         // CALLDATACOPY(t, f, s): msg.data 의 f번째 위치에서 s개의 바이트를 읽어 메모리의 t번째 위치에 저장합니다.
    //         calldatacopy(0, 0, calldatasize())
 
    //         // Call the implementation.
    //         // out and outsize are 0 because we don't know the size yet.

    //         // delegatecall(g, a, in, insize, out, outsize) -
    //         // - call contract at address a
    //         // - with input mem[in…(in+insize))
    //         // - providing g gas
    //         // - and output area mem[out…(out+outsize))
    //         // - returning 0 on error (eg. out of gas) and 1 on success
    //         let result := delegatecall(gas(), _implementation, 0, calldatasize(), 0, 0)

    //         // Copy the returned data.
    //         // returndatacopy(t, f, s) - copy s bytes from returndata at position f to mem at position t
    //         // returndatasize() - size of the last returndata
    //         returndatacopy(0, 0, returndatasize())

    //         switch result
    //         // delegatecall returns 0 on error.
    //         case 0 {
    //             // revert(p, s) - end execution, revert state changes, return data mem[p…(p+s))
    //             revert(0, returndatasize())
    //         }
    //         default {
    //             // return(p, s) - end execution, return data mem[p…(p+s))
    //             return(0, returndatasize())
    //         }
    //     }
    // }

    fallback() external payable {
        _delegate();
    }

    receive() external payable {
        _delegate();
    }
    
    function upgradeTo(address _implementation) external {
        require(msg.sender == admin, "not authorized");

        implementation = _implementation;
    }
}

// contract ProxyAdmin {
//     address public owner;

//     constructor() {
//         owner = msg.sender;
//     }

//     modifier onlyOwner() {
//         require(msg.sender == owner, "not authorized");
//         _;
//     }

//     function changeProxyAdmin(address payable proxy,address _admin) external onlyOwner {
//         Proxy(proxy).changeAdmin(_admin);
//     }

//     function upgrade(address payable proxy,address _implementation) external onlyOwner {
//         Proxy(proxy).upgradeTo(_implementation);
//     }
// }

// contract Proxy {
//     bytes32 private constant IMPLEMENTATION_SLOT = bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1);

//     bytes32 private constant ADMIN_SLOT = bytes32(uint256(keccak256("eip1967.proxy.admin")) - 1);


//     constructor() {
//         _setAdmin(msg.sender);
//     }

//     function _delegate(address _implementation) private {
//         assembly {
//             // Copy msg.data. We take full control of memory in this inline assembly
//             // block because it will not return to Solidity code. We overwrite the
//             // Solidity scratch pad at memory position 0.

//             // calldatacopy(t, f, s)
//             // - copy s bytes from calldata at position f to mem at position t
//             // calldatasize() - size of call data in bytes

//             // CALLDATASIZE: msg.data의 길이를 반환합니다. 이 때 단위는 “바이트" 입니다.
//             // CALLDATACOPY(t, f, s): msg.data 의 f번째 위치에서 s개의 바이트를 읽어 메모리의 t번째 위치에 저장합니다.
//             calldatacopy(0, 0, calldatasize())
 
//             // Call the implementation.
//             // out and outsize are 0 because we don't know the size yet.

//             // delegatecall(g, a, in, insize, out, outsize) -
//             // - call contract at address a
//             // - with input mem[in…(in+insize))
//             // - providing g gas
//             // - and output area mem[out…(out+outsize))
//             // - returning 0 on error (eg. out of gas) and 1 on success
//             let result := delegatecall(gas(), _implementation, 0, calldatasize(), 0, 0)

//             // Copy the returned data.
//             // returndatacopy(t, f, s) - copy s bytes from returndata at position f to mem at position t
//             // returndatasize() - size of the last returndata
//             returndatacopy(0, 0, returndatasize())

//             switch result
//             // delegatecall returns 0 on error.
//             case 0 {
//                 // revert(p, s) - end execution, revert state changes, return data mem[p…(p+s))
//                 revert(0, returndatasize())
//             }
//             default {
//                 // return(p, s) - end execution, return data mem[p…(p+s))
//                 return(0, returndatasize())
//             }
//         }
//     }
//     function _fallback() private {
//         _delegate(_getImplementation());
//     }
//     fallback() external payable {
//         _fallback();
//     }

//     receive() external payable {
//         _fallback();
//     }

//     // 로직과 겹치는 함수에 추가
//     modifier ifAdmin() {
//         if(msg.sender == _getAdmin()) {
//             _;
//         } else {
//             _fallback();
//         }
//     }

//     function changeAdmin(address _admin) external ifAdmin {
//         _setAdmin(_admin);
//     }
    
//     function upgradeTo(address _implementation) external ifAdmin() {
//         // require(msg.sender == _getAdmin(), "not authorized");
//         _setImplementation(_implementation);
//     }

//     function _getAdmin() private view returns(address) {
//         return StorageSlot.getAddressSlot(ADMIN_SLOT).value;
//     }

//     function _setAdmin(address _admin) private {
//         require(_admin != address(0),"admin = zero admin");
//         StorageSlot.getAddressSlot(ADMIN_SLOT).value = _admin;
//     }

//     function _getImplementation() private view returns(address) {
//         return StorageSlot.getAddressSlot(IMPLEMENTATION_SLOT).value;
//     }

//     function _setImplementation(address _implementation) private {
//         require(_implementation.code.length > 0,"_implementation not a contract");
//         StorageSlot.getAddressSlot(IMPLEMENTATION_SLOT).value = _implementation;
//     }
// }

// library StorageSlot {
//     struct AddressSlot {
//         address value;
//     }

//     function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
//         assembly {
//             r.slot :=slot
//         }
//     }
// }


// abstract contract ERC1967Upgrade {

//     // bytes32(uint256(keccak256('eip1967.proxy.implementation')) - 1));
//     bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

//     event Upgraded(address indexed implementation);

//     function _getImplementation() internal view returns (address) {
// 		return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
// 	}

// 	function _setImplementation(address newImplementation) private {
// 		require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
// 		StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
// 	}

//     function _upgradeTo(address newImplementation) internal {
//         _setImplementation(newImplementation);
//         emit Upgraded(newImplementation);
//     }

//     function _upgradeToAndCall(
//         address newImplementation,
//         bytes memory data,
//         bool forceCall
//     ) internal {
//         _upgradeTo(newImplementation);
//         if (data.length > 0 || forceCall) {
//             Address.functionDelegateCall(newImplementation, data);
//         }
//     }
// }

// abstract contract Proxy {

//     function _delegate(address _implementation) internal virtual {
//         assembly {
//             // Copy msg.data. We take full control of memory in this inline assembly
//             // block because it will not return to Solidity code. We overwrite the
//             // Solidity scratch pad at memory position 0.
//             calldatacopy(0, 0, calldatasize())
//             // Call the implementation.
//             // out and outsize are 0 because we don't know the size yet.
//             let result := delegatecall(gas(), _implementation, 0, calldatasize(), 0, 0)
//             // Copy the returned data.
//             returndatacopy(0, 0, returndatasize())
//             switch result
//             // delegatecall returns 0 on error.
//             case 0 {
//                 revert(0, returndatasize())
//             }
//             default {
//                 return(0, returndatasize())
//             }
//         }
//     }

//     function _fallback() internal virtual {
//         _beforeFallback();
//         _delegate(_implementation());
//     }

// 	fallback() external payable virtual {
//         _fallback();
//     }

//     function _implementation() public view virtual returns (address);
//     function _beforeFallback() internal virtual {}
// }

// contract ERC1967Proxy is Proxy, ERC1967Upgrade {

//     constructor(address _logic, bytes memory _data) payable {
//         _upgradeToAndCall(_logic, _data, false);
//     }

//     function _implementation() public view virtual override returns (address impl) {
//         return ERC1967Upgrade._getImplementation();
//     }
// }