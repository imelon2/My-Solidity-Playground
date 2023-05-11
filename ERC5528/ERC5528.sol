// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;
import {IERC5528} from "./IERC5528.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract EscrowContract is IERC5528 {

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

    address DKR; // 판매(buyer) 재화
    address tUSDT; // 구매(seller) 재화

    constructor(address _DKR, address _tUSDT) {
        DKR = _DKR;
        tUSDT = _tUSDT;
    }

    function escrowFund(address _to, uint256 _value) public returns (bool){
        if(msg.sender == DKR){
            require(_status == State.Running, "must be running state");
            _seller.addr = _to;
            _seller.amount = _value;
            _status = State.Success;
        }else if(msg.sender == tUSDT){
            require(_status == State.Inited, "must be init state");
            _buyer.addr = _to;
            _buyer.amount = _value;
            _status = State.Running;
        }else{
            require(false, "Invalid to address");
        }

        return true;
    }

    function escrowRefund(address _from, uint256 _value) public returns (bool){
        require(_status == State.Running, "refund is only available on running state");
        require(msg.sender == address(tUSDT), "invalid caller for refund");
        require(_buyer.addr == _from, "only buyer can refund");
        require(_buyer.amount >= _value, "buyer fund is not enough to refund");
        _buyer.amount = _buyer.amount - _value;
        return true;
    }

    function escrowWithdraw() external returns (bool) {
        require(_status == State.Success, "withdraw is only available on success state");
        uint256 common = _min(_seller.amount, _buyer.amount);

        if(common > 0){
            _buyer.amount = _buyer.amount - common;
            _seller.amount = _seller.amount - common;

            // Exchange
            IERC20(DKR).transfer(_buyer.addr, common);
            IERC20(tUSDT).transfer(_seller.addr, common);

            // send back the remaining balances
            if(_buyer.amount > 0){
                IERC20(DKR).transfer(_buyer.addr, _buyer.amount);
            }
            if(_seller.amount > 0){
                IERC20(tUSDT).transfer(_seller.addr, _seller.amount);
            }
        }

        _status = State.Closed;

        return true;
    }

    function _min(uint x, uint y) private pure returns(uint) {
        return x <= y ? x : y;
    }

    function getStatus() public view returns(State) {
        return _status;
    }
}