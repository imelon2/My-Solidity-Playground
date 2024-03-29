
// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.10;
import {ERC2770} from "./ERC2770.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract FeeDelegatoer is ERC2770,Ownable {
    constructor(string memory name,string memory version) ERC2770(name, version) {}

    function execute(ForwardRequest calldata req, bytes calldata signature) public payable override onlyOwner returns(bool,bytes memory) {
        return super.execute(req,signature);
    }
}

//["0x5B38Da6a701c568545dCfcB03FcB875f56beddC4","0x5FD6eB55D12E759a21C09eF703fe0CBa1DC9d88D","0","300000","2","0xa9059cbb0000000000000000000000004b20993bc481177ec7e8f571cecae8a9e22c02db00000000000000000000000000000000000000000000000000000000000003e8"]
