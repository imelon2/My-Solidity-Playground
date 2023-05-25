// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;
import {IERC5528} from "./interface/IERC5528.sol";
import {ERC2771Context} from "./ERC2771.sol";
import {Dkargo} from "./ERC20.sol";

contract EscrowContract is ERC2771Context {

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


    BalanceData _seller;
    BalanceData _buyer;
    State _status;
    address tokenAddress;

    constructor(address seller, address buyer,address _tokenAddress, address _trustedForwarder) ERC2771Context(_trustedForwarder) {
        _seller.addr = seller;
        _buyer.addr = buyer;
        tokenAddress = _tokenAddress;
    }

    function sendToken(address owner, uint256 amount, uint256 deadline,uint8 v,bytes32 r, bytes32 s) public returns(bool) {
        Dkargo(tokenAddress).permit(owner, address(this), amount, deadline, v, r, s);
        Dkargo(tokenAddress).transferFrom(owner,address(this),amount);

        return escrowFund(owner,amount);
    }

    function escrowFund(address, uint256 _value) internal returns (bool){
        if(_msgSender() == _seller.addr){
            require(_status == State.Running, "must be running state");
            _seller.amount = _value;
            _status = State.Success;
        }else if(_msgSender() == _buyer.addr){
            require(_status == State.Inited, "must be init state");
            _buyer.amount = _value;
            _status = State.Running;
        }else{
            require(false, "Invalid to address");
        }

        return true;
    }

    function escrowRefund(address _from, uint256 _value) public returns (bool){
        require(_status == State.Running, "refund is only available on running state");
        require(_msgSender() == _buyer.addr, "invalid caller for refund");
        require(_buyer.addr == _from, "only buyer can refund");
        require(_buyer.amount >= _value, "buyer fund is not enough to refund");
        _buyer.amount = _buyer.amount - _value;
        return true;
    }

    function escrowWithdraw() external returns (bool) {
        require(_status == State.Success, "withdraw is only available on success state");
        Dkargo(tokenAddress).transfer(_buyer.addr,_buyer.amount + _seller.amount);
        _status = State.Closed;

        return true;
    }

    function getStatus() public view returns(State) {
        return _status;
    }
}