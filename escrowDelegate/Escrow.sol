// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {IERC5528} from "./interface/IERC5528.sol";
import {ERC2771Context} from "./ERC2771.sol";
// import {ERC1363Payable} from "./ERC1363Payable.sol";
import "./ERC20.sol";


// contract Escrow is IERC5528,ERC1363Payable {
contract Escrow is ERC2771Context {
    enum State { 
        Inited, // 거래가 없는 상태
        Running, // 거래 요청 상태
        Success, // 거래 매칭 성공 상태
        Closed // 거래 완료(종료) 상태
    }   

    struct BalanceData {
        address addr;
        uint256 amount;
    }


    BalanceData seller;
    BalanceData buyer;

    address tokenAddress;

    State _status;

    constructor(address _seller,address _buyer,address _tokenAddress,address _FeeDelegator) ERC2771Context(_FeeDelegator) {
        seller.addr = _seller;
        buyer.addr = _buyer;

        tokenAddress = _tokenAddress;
    }
    
    function sendToken(address owner, uint256 value, uint256 deadline,uint8 v,bytes32 r, bytes32 s) public {
        Dkargo(tokenAddress).permit(owner,address(this),value,deadline, v, r, s);
        Dkargo(tokenAddress).transferFrom(owner,address(this),value);

        escrowFund(owner,value);
    }   

    function escrowFund(address _to, uint256 _value) internal returns (bool){
        if(_msgSender() == _to) {
            require(_status == State.Running, "must be running state");
            seller.amount = _value;
            _status = State.Success;
        } else if(_msgSender() == _to) {
            require(_status == State.Inited, "must be init state");
            buyer.amount = _value;
            _status = State.Running;
        }else{
            require(false, "Invalid to address");
        }

        return true;
    }

    function escrowRefund() public returns (bool){
        require(_status == State.Running, "refund is only available on running state");
        require(_msgSender() == buyer.addr, "invalid caller for refund");

        Dkargo(tokenAddress).transfer(buyer.addr,buyer.amount);

        _status = State.Inited;
        return true;
    }

    function escrowWithdraw() external returns (bool) {
        return true;
    }

    function _min(uint x, uint y) private pure returns(uint) {
        return x <= y ? x : y;
    }
}