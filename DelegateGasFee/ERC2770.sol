// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.10;
import "@openzeppelin/contracts/utils/cryptography/EIP712.sol";

abstract contract ERC2770 is EIP712 {
    using ECDSA for bytes32;

    // meta data
    struct ForwardRequest {
        address from;
        address to;
        uint256 value;
        uint256 gas;
        uint256 nonce;
        bytes data;
    }

    mapping(address => uint256) private _nonces;

    constructor(string memory name,string memory version) EIP712(name, version) {}

    bytes32 private constant _TYPEHASH =
        keccak256("ForwardRequest(address from,address to,uint256 value,uint256 gas,uint256 nonce,bytes data)");


    function getNonce(address from) public view returns (uint256) {
        return _nonces[from];
    }

    function verify(ForwardRequest calldata req, bytes calldata signature) public view returns (bool) {
        address signer = _hashTypedDataV4(
            keccak256(abi.encode(_TYPEHASH, req.from, req.to, req.value, req.gas, req.nonce, keccak256(req.data)))
        ).recover(signature);
        return _nonces[req.from] == req.nonce && signer == req.from;
    }

    function execute(
        ForwardRequest calldata req,
        bytes calldata signature
    ) public payable returns (bool, bytes memory) {
        require(verify(req, signature), "MinimalForwarder: signature does not match request");
        _nonces[req.from] = req.nonce + 1;

        (bool success, bytes memory returndata) = req.to.call{gas: req.gas, value: req.value}(
            abi.encodePacked(req.data, req.from)
        );


        if (gasleft() <= req.gas / 63) {
            // We explicitly trigger invalid opcode to consume all gas and bubble-up the effects, since
            // neither revert or assert consume all gas since Solidity 0.8.0
            // https://docs.soliditylang.org/en/v0.8.0/control-structures.html#panic-via-assert-and-error-via-require
            /// @solidity memory-safe-assembly
            assembly {
                invalid()
            }
        }

        return (success, returndata);
    }



}


// ["0xd644352A429F3fF3d21128820DcBC53e063685b1","0x26b989b9525Bb775C8DEDf70FeE40C36B397CE67","0","30000","0","0x4000aea000000000000000000000000026b989b9525bb775c8dedf70fee40c36b397ce670000000000000000000000000000000000000000000000008ac7230489e80000000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000000247f02eb76000000000000000000000000d644352a429f3ff3d21128820dcbc53e063685b100000000000000000000000000000000000000000000000000000000"]