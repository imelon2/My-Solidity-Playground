// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/Address.sol"; 
import "@openzeppelin/contracts/interfaces/IERC20.sol"; 
import "@openzeppelin/contracts/utils/cryptography/EIP712.sol"; 
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/metatx/ERC2771Context.sol";
import "./interface/IOrderRules.sol";
import "./SBTMinter.sol";
import "./interface/IDKA.sol";

contract Order is EIP712, ERC2771Context {

    //events 
    event orderCreated(uint256 orderId, shippingState state);
    event orderMatched(uint256 orderId, shippingState state);
    event carrierpickUp(uint256 orderId, shippingState state);
    event orderCompleted(uint256 orderId, shippingState state);
    event orderCanceled(uint256 orderId, shippingState state);
    event orderFailed(uint256 orderId, shippingState state);

    enum shippingState { 
        ORDER_REGISTERED,  //shipper의 주문 등록 완료
        FINALIZED_CARRIER,  //캐리어와 shipper 매칭 완료
        CARRIER_PICKUP,   //캐리어 픽업
        DELIVERY_COMPLETE, //배송완료
        CARRIER_PICKUP_DELAY, // 캐리어 픽업 딜레이
        DELIVERY_EXPIRED,  //배송 실패 (배송 딜레이)
		DELIVERY_CANCEL  //배송 취소
    }
    
    //@notice 유저 별 배송 성공/실패/취소 케이스 저장을 위한 struct
    struct TrackContributions {
        uint256 completeOrder_shipping; //화주 배송 성공 케이스
        uint256 completeOrder_carrying; //화주 배송 성공 케이스
        uint256 expiredOrder; //배송 실패 (딜레이) 케이스
        uint256 failOrder; //배송 취소 (귀책사유 존재) 케이스
    }

    //@notice 각 유저의 주소 별로 배송 성공/실패/취소 케이스 트래킹
    mapping (address => TrackContributions) private trackContributions;

    //@notice 각 오더 ID에 할당된 필요정보들을 모아보기 위함
    struct order {
        uint256 _orderId; //주문 id
        address _shipper; //shipper의 주소
        address _carrier; //carrier의 주소
        bytes32 _departure; //출발지
        bytes32 _destination; //목적지
        bytes32 _packageWeight; //물품규격 (무게)       
        uint256 _price; //물품가액
        uint256 _reward; //shipper의 지급 리워드
        uint256 _collateral; //캐리어의 담보금
        uint256 _failDate;//실패시간
        uint256 _pickupDate; //캐리어가 물건을 픽업해야 하는 시간
        uint256 _expiredDate; //배송 완료되어야 할 기간
        shippingState _shipState; //배송상태 식별자 
        bool isDirect;
        bool ispickupContact;
        bool iscompleteContact;
    }

    struct cancelFlag {
        uint256 _orderId; //주문 id
        bool shipperLock;
        bool carrierLock;
        bool canceled;
    }

    //@notice 주문 생성될때마다 +1씩 증가 될 order Id
    uint256 orderId;

    //@notice Struct order의 list 정의
    mapping(uint256 => order) private orderList;
    mapping(uint256 => cancelFlag) private cancelList;

    mapping(uint256 => mapping(address => uint256)) private _nonces; // ---> 변수명?
        
    //@notice ERC1363/2612 구현 컨트랙트 
    address _orderRules;

    //@notice 캐리어의 sig를 반환받아 메시지 서명자가 캐리어인지 확인하기 위해 정의된 struct
    //@dev function selectOrder에서 사용될 것
    struct OrderSigData {
        uint256 orderId; //주문 id
        address shipper; //shipper의 주소
        address carrier; //캐리어의 주소
        bytes32 departure; //출발지
        bytes32 destination; //목적지
        bytes32 packageWeight; //물품규격 (무게)
        uint256 packagePrice; //물품 가액 
        uint256 reward; //shipper의 보상 리워드
        uint256 collateral; //캐리어의 담보금 
        uint256 expiredDate; //배송 완료되어야 할 기간
        uint256 nonce; //해당 address의 nonce  ---> sequential 하게 증가하진않음
    }

    struct PermitSigData {
        address owner;
        address spender;
        uint256 value;
        uint256 nonce;
        uint256 deadline;
    }

    //@notice 검증을 위한 struct typehash 정의  
    bytes32 constant ORDERTOSIGN_TYPEHASH = keccak256("OrderSigData(uint256 orderId,address shipper,address carrier,bytes32 departure,bytes32 destination,bytes32 packageWeight,uint256 packagePrice,uint256 reward,uint256 collateral,uint256 expiredDate,uint256 nonce)");

    constructor(address orderRules, address forwarder ) EIP712("Order","1") ERC2771Context( forwarder ) {
        _orderRules = orderRules;
        orderId = 1;
    }
    
    //@notice 주문 생성 및 오더 id 부여/ shippingState ORDER_REGISTERED 로 변경 
    //@dev 주문이 이미 생성되었는지 modifier로 확인, 주문생성 이벤트 emit
    //@dev orderId +1씩 증가
    //@param shipper shipper 주소
    //@param locPackage 주문 출발지/목적지/물품규격 정의된 코드 1174011000
    //@param expiredDate 배송완료되어야 할 기간 
    function createOrder (address shipper, bytes32 departure, bytes32 destination, bytes32 weight, uint256 price, uint256 expiredDate, bool pickupType, bool completeType, string memory extraData) external returns (uint256) {
        require(_msgSender() == shipper, "order must be created by self");
        uint256 _orderId = getOrderId();
        require(orderList[_orderId]._shipper == address(0), "order already exist");
        orderList[_orderId]._orderId = _orderId;
        orderList[_orderId]._shipper = shipper;
        orderList[_orderId]._departure = departure;
        orderList[_orderId]._destination = destination;
        orderList[_orderId]._packageWeight = weight;
        orderList[_orderId]._price = price;
        orderList[_orderId]._collateral = price/10;
        

        if(expiredDate == 0) {
            orderList[_orderId].isDirect = true;
            orderList[_orderId]._expiredDate = block.timestamp + IOrderRules(_orderRules).getTimeExpiredWaitMatching();
        } else {            
            orderList[_orderId].isDirect = false;
            orderList[_orderId]._expiredDate = expiredDate - 3 hours;
        }

        orderList[_orderId].ispickupContact = pickupType;
        orderList[_orderId].iscompleteContact = completeType;
        orderList[_orderId]._shipState = shippingState.ORDER_REGISTERED;
        emit orderCreated(orderId, shippingState.ORDER_REGISTERED);

        orderId++;

        return _orderId;
    }
        
    //@notice 매칭된 캐리어의 담보금과 shipper의 리워드를 보관
    //@dev 캐리어의 시그니처 및 shipper의 시그니처가 각 메시지 서명자인지 확인하고,담보와 리워드를 token contract의 escrowFund를 이용하여 보관한다. 
    //@param Order order order 스트럭트
    //@param carrierFee712Sig 캐리어의 제시금액을 서명한 EIP712 기반 signed msg
    //@param carrierCollateral2612Sig 캐리어의 담보금을 보관하겠다는 EIP2612 기반 signed msg
    //@param shipper712Sig shipper의 리워드 및 캐리어 매칭 정보를 담은 EIP2612 기반 signed msg
    function selectOrder(uint256 _orderId,
        OrderSigData memory carrierOrderData, bytes memory carrierOrderSig,
        PermitSigData memory carrierPermitData, bytes memory carrierCollateralSig,
        PermitSigData memory shipperPermitData, bytes memory shipperRewardSig) external {
            require(orderList[_orderId]._orderId != 0, "order not exist");
            require(orderList[_orderId]._shipState == shippingState.ORDER_REGISTERED, "only not matched order can be matched");
            require(block.timestamp < orderList[_orderId]._expiredDate, "order match time expired");
            require(_msgSender() == orderList[_orderId]._shipper, "only shipper can select carrier");

            bytes32 structhash = hashStruct(carrierOrderData);
            (address signer,) = ECDSA.tryRecover(_hashTypedDataV4(structhash), carrierOrderSig);
            require(signer == carrierOrderData.carrier, "Order Signature invalid");
            _useNonce(_orderId, carrierOrderData.carrier);

            address _tokenContract = IOrderRules(_orderRules).getDKATokenAddress();

            uint256 delay = IOrderRules(_orderRules).getTimeExpiredDelayedPick();

            IDKA(_tokenContract).permitLodis(carrierPermitData.owner, address(this), carrierPermitData.value, carrierPermitData.deadline, carrierCollateralSig);
            IDKA(_tokenContract).transferFrom(carrierPermitData.owner, address(this), carrierPermitData.value);

            // 리워드 혹은 담보가 40dka가 안되는 경우 체크 필요
            IDKA(_tokenContract).permitLodis(shipperPermitData.owner, address(this), shipperPermitData.value, shipperPermitData.deadline, shipperRewardSig);
            IDKA(_tokenContract).transferFrom(shipperPermitData.owner, address(this), shipperPermitData.value);

            //update order
            orderList[_orderId]._carrier = carrierOrderData.carrier;
            orderList[_orderId]._reward = carrierOrderData.reward;

            //pick Data seting
            if(orderList[_orderId].isDirect = true) {
                orderList[_orderId]._pickupDate = block.timestamp + delay;
                orderList[_orderId]._failDate = block.timestamp + IOrderRules(_orderRules).getTimeExpiredDeliveryFault();
            } else {
                orderList[_orderId]._pickupDate = orderList[_orderId]._expiredDate - delay;
                orderList[_orderId]._failDate = orderList[_orderId]._expiredDate + 3 hours;
            }   
            orderList[_orderId]._shipState = shippingState.FINALIZED_CARRIER;
            emit orderMatched(_orderId, shippingState.FINALIZED_CARRIER);
    }

    //@notice 매칭이전 취소
    function cancelOrderBeforeMatch(uint256 _orderId) external {
        require(_msgSender() == orderList[_orderId]._shipper, "order should be canceled by users");
        require(orderList[_orderId]._shipState == shippingState.ORDER_REGISTERED, "only order before match can be canceled");

        orderList[_orderId]._shipState = shippingState.DELIVERY_CANCEL;
    }

    //@notice 캐리어의 물품이 픽업 되었을 경우, shipper의 시그니처를 검증한 후, shippingState CARRIER_PICKUP으로 변경
    //@dev orderID가 등록되어 있는지 확인/ 상태가 캐리어 매칭 후 인지 확인 /각 정보가 orderList에 존재하는지 확인
    //@param Order order order 스트럭트
    //@param shipperSig shipper의 signed msg 
    function pickOrder(
        uint256 _orderId,
        OrderSigData memory shipperOrderData,
        bytes memory shipperMsg) external {
            require(orderList[_orderId]._shipState == shippingState.FINALIZED_CARRIER, "order not matched");
            require(_msgSender() == orderList[_orderId]._carrier, "only carrier can pick baggage");
            require(orderList[_orderId]._pickupDate > block.timestamp, "order should not be delayed");
            require(orderList[_orderId].ispickupContact == true, "face-to-face pickup");

            bytes32 structhash = hashStruct(shipperOrderData);
            (address signer,) = ECDSA.tryRecover(_hashTypedDataV4(structhash), shipperMsg);
            require(signer == shipperOrderData.shipper, "Order Signature invalid");
            _useNonce(_orderId, shipperOrderData.shipper);

            orderList[_orderId]._shipState = shippingState.CARRIER_PICKUP;
            emit carrierpickUp(_orderId, shippingState.CARRIER_PICKUP);
    }

    function pickOrderWithOutSig(uint256 _orderId) external {        
        require(orderList[_orderId]._shipState == shippingState.FINALIZED_CARRIER, "order not matched");
        require(_msgSender() == orderList[_orderId]._carrier, "only carrier can pick baggage");
        require(orderList[_orderId]._pickupDate > block.timestamp, "order should not be delayed");
        require(orderList[_orderId].ispickupContact == false, "non-contact pickup");

        orderList[_orderId]._shipState = shippingState.CARRIER_PICKUP;
        emit carrierpickUp(_orderId, shippingState.CARRIER_PICKUP);
    }

    //@notice 픽업이전 유저에 의한 일방적인 취소
    function cancelOrderBeforePickUp(uint256 _orderId) external {
        require(_msgSender() == orderList[_orderId]._carrier || _msgSender() == orderList[_orderId]._shipper, "order should be canceled by users");
        require(orderList[_orderId]._shipState == shippingState.FINALIZED_CARRIER, "order not matched");
        require(orderList[_orderId]._pickupDate > block.timestamp, "order should not be delayed");

        address _tokenContract = IOrderRules(_orderRules).getDKATokenAddress();
        uint256 platformFee = IOrderRules(_orderRules).getPlatformFee();
        
        orderList[_orderId]._shipState = shippingState.DELIVERY_CANCEL;
        if(_msgSender() ==  orderList[_orderId]._shipper) {
            uint256 shipperFee = orderList[_orderId]._reward * IOrderRules(_orderRules).getShipperFee() / 100;
            IDKA(_tokenContract).transfer(orderList[_orderId]._shipper, orderList[_orderId]._reward - shipperFee - platformFee);
            IDKA(_tokenContract).transfer(orderList[_orderId]._carrier, orderList[_orderId]._collateral + shipperFee);
            IDKA(_tokenContract).transfer(IOrderRules(_orderRules).getTreasuryAddress(), platformFee);
        } else if(_msgSender() == orderList[_orderId]._carrier) {
            uint256 carrierFee = orderList[_orderId]._collateral * IOrderRules(_orderRules).getCarrierFee() / 100;
            IDKA(_tokenContract).transfer(orderList[_orderId]._shipper, orderList[_orderId]._reward + carrierFee);

            if(orderList[_orderId]._collateral - carrierFee < platformFee) {
                IDKA(_tokenContract).transfer(IOrderRules(_orderRules).getTreasuryAddress(), orderList[_orderId]._collateral - carrierFee);
            } else {
                IDKA(_tokenContract).transfer(orderList[_orderId]._carrier, orderList[_orderId]._collateral - carrierFee - platformFee);
                IDKA(_tokenContract).transfer(IOrderRules(_orderRules).getTreasuryAddress(), platformFee);
            }
        }
        emit orderCanceled(_orderId, shippingState.DELIVERY_CANCEL);
    }

    //@notice 픽업 시간 초과로 인한 shipper의 취소 요청
    function delayPickUp(uint256 _orderId) external {     
        require(_msgSender() == orderList[_orderId]._shipper, "only shipper can cancel by delay");
        require(orderList[_orderId]._shipState == shippingState.FINALIZED_CARRIER, "order not matched");
        require(orderList[_orderId]._pickupDate < block.timestamp, "order is not delayed");

        address _tokenContract = IOrderRules(_orderRules).getDKATokenAddress();
        uint256 carrierFee = orderList[_orderId]._collateral * IOrderRules(_orderRules).getCarrierFee() / 100;
        uint256 platformFee = IOrderRules(_orderRules).getPlatformFee();

        orderList[_orderId]._shipState = shippingState.CARRIER_PICKUP_DELAY;

        IDKA(_tokenContract).transfer(orderList[_orderId]._shipper, orderList[_orderId]._reward + carrierFee);

        if(orderList[_orderId]._collateral - carrierFee < platformFee) {
            IDKA(_tokenContract).transfer(IOrderRules(_orderRules).getTreasuryAddress(), orderList[_orderId]._collateral - carrierFee);
        } else {
            IDKA(_tokenContract).transfer(orderList[_orderId]._carrier, orderList[_orderId]._collateral - carrierFee - platformFee);
            IDKA(_tokenContract).transfer(IOrderRules(_orderRules).getTreasuryAddress(), platformFee);
        }

        trackContributions[orderList[_orderId]._shipper].expiredOrder++;
        trackContributions[orderList[_orderId]._carrier].expiredOrder++;
        emit orderCanceled(_orderId, shippingState.CARRIER_PICKUP_DELAY);
    }

    //@notice 배송이 성공적으로 완료되었을 경우, 캐리어에게 리워드 지급/담보금 반환한다
    //@dev expiredDate 이전에 배송이 완료되었는지 확인한다 / 배송완료 이벤트를 emit / 상태변경 / shipper 시그니처 확인
    //@dev 캐리어의 TrackContribution 상태 업데이트하고, treasury에 수수료 출금
    //@dev SBT 조건 체크
    //@param orderId 주문 ID
    //@param shipper712Sig shipper의 시그니처
    function completeOrder(uint256 _orderId, OrderSigData memory receiverOrderData, bytes memory shipper712Sig) external {
        require(_msgSender() == orderList[_orderId]._carrier, "only carrier can complete delivery");
        require(orderList[_orderId]._shipState == shippingState.CARRIER_PICKUP, "order not started");
        require(orderList[_orderId].iscompleteContact == true, "face-to-face complete");

        bytes32 structhash = hashStruct(receiverOrderData);
        (address signer,) = ECDSA.tryRecover(_hashTypedDataV4(structhash), shipper712Sig);
        require(signer == receiverOrderData.shipper, "Order Signature invalid");
        _useNonce(_orderId, receiverOrderData.shipper);

        orderList[_orderId]._shipState = shippingState.DELIVERY_COMPLETE;
        uint256 escrowAmount = orderList[_orderId]._reward + orderList[_orderId]._collateral;

        address _tokenContract = IOrderRules(_orderRules).getDKATokenAddress();
        uint256 platformFee = IOrderRules(_orderRules).getPlatformFee();

        IDKA(_tokenContract).transfer(IOrderRules(_orderRules).getTreasuryAddress(), platformFee);
        IDKA(_tokenContract).transfer(orderList[_orderId]._carrier, escrowAmount - platformFee);

        trackContributions[orderList[_orderId]._shipper].completeOrder_shipping++;
        trackContributions[orderList[_orderId]._carrier].completeOrder_carrying++;

        SBTMinter(IOrderRules(_orderRules).getSBTMinterAddress()).checkAvailableSBTs(orderList[_orderId]._carrier, IOrderRules(_orderRules).getCarrierSBTAddress());
        SBTMinter(IOrderRules(_orderRules).getSBTMinterAddress()).checkAvailableSBTs(orderList[_orderId]._shipper, IOrderRules(_orderRules).getShipperSBTAddress());

        emit orderCompleted(_orderId, shippingState.DELIVERY_COMPLETE);
    }

    function completeOrderWithOutSig(uint256 _orderId) external {
        require(_msgSender() == orderList[_orderId]._carrier, "only carrier can complete delivery");
        require(orderList[_orderId]._shipState == shippingState.CARRIER_PICKUP, "order not started");
        require(orderList[_orderId].iscompleteContact == false, "non-Contact complete");
        
        address _tokenContract = IOrderRules(_orderRules).getDKATokenAddress();
        uint256 platformFee = IOrderRules(_orderRules).getPlatformFee();

        orderList[_orderId]._shipState = shippingState.DELIVERY_COMPLETE;
        uint256 escrowAmount = orderList[_orderId]._reward + orderList[_orderId]._collateral;

        IDKA(_tokenContract).transfer(IOrderRules(_orderRules).getTreasuryAddress(), platformFee);
        IDKA(_tokenContract).transfer(orderList[_orderId]._carrier, escrowAmount - platformFee);

        trackContributions[orderList[_orderId]._shipper].completeOrder_shipping++;
        trackContributions[orderList[_orderId]._carrier].completeOrder_carrying++;

        SBTMinter(IOrderRules(_orderRules).getSBTMinterAddress()).checkAvailableSBTs(orderList[_orderId]._carrier, IOrderRules(_orderRules).getCarrierSBTAddress());
        SBTMinter(IOrderRules(_orderRules).getSBTMinterAddress()).checkAvailableSBTs(orderList[_orderId]._shipper, IOrderRules(_orderRules).getShipperSBTAddress());
        
        emit orderCompleted(_orderId, shippingState.DELIVERY_COMPLETE);
    }

    //@notice 배송이 실패 (딜레이) 되었을 경우, shipper에게 리워드/담보금 지급한다
    //@dev expiredDate 후에 배송 완료인지 확인/배송딜레이 이벤트 emit/시그니처 확인
    //@dev 캐리어의 TrackContribution 상태 업데이트하고, treasury에 수수료 출금
    //@param orderId 주문 ID
    function expiredOrder(uint256 _orderId) external {
        require(_msgSender() == orderList[_orderId]._shipper, "only shipper can expire delivery");
        require(orderList[_orderId]._shipState == shippingState.CARRIER_PICKUP, "order not started");

        require(orderList[_orderId]._failDate < block.timestamp, "order is not expired");
        
        address _tokenContract = IOrderRules(_orderRules).getDKATokenAddress();
        uint256 platformFee = IOrderRules(_orderRules).getPlatformFee();

        orderList[_orderId]._shipState = shippingState.DELIVERY_EXPIRED;
        
        uint256 escrowAmount = orderList[_orderId]._reward + orderList[_orderId]._collateral;

        IDKA(_tokenContract).transfer(IOrderRules(_orderRules).getTreasuryAddress(), platformFee);
        IDKA(_tokenContract).transfer(orderList[_orderId]._shipper, escrowAmount - platformFee);

        trackContributions[orderList[_orderId]._shipper].failOrder++;
        trackContributions[orderList[_orderId]._carrier].failOrder++;
        emit orderFailed(_orderId, shippingState.DELIVERY_EXPIRED);
    }

    //@notice 배송이 취소되었을 경우, 규책사유에 따라 리워드 지급/담보금 반환 [기획 요청에 따른 협의]
    //양측 tx받아서 두개의 flag다 true되면 lockup해제
    function cancelOrderByFault (uint256 _orderId, OrderSigData memory cancelData, bytes memory cancelSig) external {
        require(_msgSender() == orderList[_orderId]._carrier || _msgSender() == orderList[_orderId]._shipper, "order should be canceled by users");
        require(orderList[_orderId]._shipState == shippingState.CARRIER_PICKUP, "order not started");

        bytes32 structhash = hashStruct(cancelData);
        (address cancelSigner,) = ECDSA.tryRecover(_hashTypedDataV4(structhash), cancelSig);

        address _tokenContract = IOrderRules(_orderRules).getDKATokenAddress();
        uint256 platformFee = IOrderRules(_orderRules).getPlatformFee();

        //check both sig and cancel
        if (cancelSigner == orderList[_orderId]._shipper) {
            cancelList[_orderId].shipperLock = true;
        } else if (cancelSigner == orderList[_orderId]._carrier) {
            cancelList[_orderId].carrierLock = true;
        }

        if (cancelList[_orderId].shipperLock && cancelList[_orderId].carrierLock && !cancelList[_orderId].canceled) {
            IDKA(_tokenContract).transfer(orderList[_orderId]._shipper, orderList[_orderId]._reward - platformFee);
            if(orderList[_orderId]._collateral - platformFee < 0) {
                IDKA(_tokenContract).transfer(IOrderRules(_orderRules).getTreasuryAddress(), platformFee + orderList[_orderId]._collateral);
            } else {
                IDKA(_tokenContract).transfer(orderList[_orderId]._carrier, orderList[_orderId]._collateral - platformFee);
                IDKA(_tokenContract).transfer(IOrderRules(_orderRules).getTreasuryAddress(), platformFee * 2);
            }
            orderList[_orderId]._shipState = shippingState.DELIVERY_CANCEL;
            cancelList[_orderId].canceled = true;
            emit orderCanceled(_orderId, shippingState.DELIVERY_CANCEL);
        } 
        
    }

    function getOrderId() public view returns (uint256) {
        return orderId;
    }
    
    function hashStruct(OrderSigData memory orderSigData) internal pure returns (bytes32) {
        return keccak256(
            abi.encode(
			    ORDERTOSIGN_TYPEHASH,
			    orderSigData.orderId, 
				orderSigData.shipper, 
				orderSigData.carrier, 
				orderSigData.departure,
                orderSigData.destination,
                orderSigData.packageWeight,
                orderSigData.packagePrice,
				orderSigData.reward, 
				orderSigData.collateral, 
				orderSigData.expiredDate,
                orderSigData.nonce)
		    );
    }

    function _useNonce(uint256 _orderId, address owner) internal virtual returns (uint256 current) {
        uint256 nonce = _nonces[_orderId][owner];
        current = nonce;
        _nonces[_orderId][owner]++;
    }

    function getNonce(uint256 _orderId, address owner) public view returns (uint256) {
        return _nonces[_orderId][owner];
    }

    function getOrder(uint256 _orderId) public view returns (order memory) {
        return orderList[_orderId];
    }

    function getRecord(address user) public view returns (TrackContributions memory) {
        return trackContributions[user];
    }
}