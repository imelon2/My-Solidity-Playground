abstract contract Manager is Ownable {
    using SafeERC20 for IERC20;
    IHouse house;
    IVRFManager VRFManager;
    
    uint constant public MODULO = 6;

    // Variables
    bool public gameIsLive;
    uint public minBetAmount = 1 ether;
    uint public maxBetAmount = 300 ether;
    uint public houseEdgeBP = 220;
    uint public nftHoldersRewardsBP = 0;

    address public VRFManagerAddress;

    struct Bet {
        uint8 rollUnder;
        uint40 choice;
        uint40 outcome;
        uint168 placeBlockNumber;
        uint128 amount;
        uint128 winAmount;
        address player;
        bool isSettled;
    }

    Bet[] public bets;
    mapping(bytes32 => uint[]) public betMap;

    modifier isVRFManager {
        require(VRFManagerAddress == msg.sender, "You are not allowed");
        _;
    }

    function betsLength() external view returns (uint) {
        return bets.length;
    }

    // Events
    event BetPlaced(uint indexed betId, address indexed player, uint amount, uint indexed rollUnder, uint choice, bool isBonus, uint note);
    event BetSettled(uint indexed betId, address indexed player, uint amount, uint indexed rollUnder, uint choice, uint outcome, uint winAmount);
    event BetRefunded(uint indexed betId, address indexed player, uint amount);

    // Setter
    function setMinBetAmount(uint _minBetAmount) external onlyOwner {
        require(_minBetAmount < maxBetAmount, "Min amount must be less than max amount");
        minBetAmount = _minBetAmount;
    }

    function setMaxBetAmount(uint _maxBetAmount) external onlyOwner {
        require(_maxBetAmount > minBetAmount, "Max amount must be greater than min amount");
        maxBetAmount = _maxBetAmount;
    }

    function setHouseEdgeBP(uint _houseEdgeBP) external onlyOwner {
        require(gameIsLive == false, "Bets in pending");
        houseEdgeBP = _houseEdgeBP;
    }

    function setNftHoldersRewardsBP(uint _nftHoldersRewardsBP) external onlyOwner {
        nftHoldersRewardsBP = _nftHoldersRewardsBP;
    }

    function toggleGameIsLive() external onlyOwner {
        gameIsLive = !gameIsLive;
    }

    // Converters
    function amountToBettableAmountConverter(uint amount) internal view returns(uint) {
        return amount * (10000 - houseEdgeBP) / 10000;
    }

    function amountToNftHoldersRewardsConverter(uint _amount) internal view returns (uint) {
        return _amount * nftHoldersRewardsBP / 10000;
    }

    function amountToWinnableAmount(uint _amount, uint rollUnder) internal view returns (uint) {
        require(0 < rollUnder && rollUnder <= MODULO, "Win probability out of range");
        uint bettableAmount = amountToBettableAmountConverter(_amount);
        return bettableAmount * MODULO / rollUnder;
    }

    // Methods
    function initializeHouse(address _address) external onlyOwner {
        require(gameIsLive == false, "Bets in pending");
        house = IHouse(_address);
    }

    function initializeVRFManager(address _address) external onlyOwner {
        require(gameIsLive == false, "Bets in pending");
        VRFManager = IVRFManager(_address);
        VRFManagerAddress = _address;
    }

    function withdrawCustomTokenFunds(address beneficiary, uint withdrawAmount, address token) external onlyOwner {
        require(withdrawAmount <= IERC20(token).balanceOf(address(this)), "Withdrawal exceeds limit");
        IERC20(token).safeTransfer(beneficiary, withdrawAmount);
    }
}

contract Dice is ReentrancyGuard, Manager, IGame {
    uint constant POPCNT_MULT = 0x0000000000002000000000100000000008000000000400000000020000000001;
    uint constant POPCNT_MASK = 0x0001041041041041041041041041041041041041041041041041041041041041;
    uint constant POPCNT_MODULO = 0x3F;

    function placeBet(uint betChoice, uint bonus, uint note) external payable nonReentrant {
        require(gameIsLive, "Game is not live");
        require(betChoice > 0 && betChoice < 2 ** MODULO - 1, "Bet mask not in range");

        uint amount = msg.value;
        bool isBonus;
        if (amount == 0) {
            isBonus = true;
            amount = bonus;
        }
        require(amount >= minBetAmount && amount <= maxBetAmount, "Bet amount not within range");

        uint rollUnder = ((betChoice * POPCNT_MULT) & POPCNT_MASK) % POPCNT_MODULO;

        uint winnableAmount = amountToWinnableAmount(amount, rollUnder);
        uint bettableAmount = amountToBettableAmountConverter(amount);
        uint nftHolderRewardsAmount = amountToNftHoldersRewardsConverter(amount - bettableAmount);
        
        house.placeBet{value: msg.value}(msg.sender, amount, isBonus, nftHolderRewardsAmount, winnableAmount);
        
        uint betId = bets.length;
        betMap[VRFManager.sendRequestRandomness()].push(betId);

        emit BetPlaced(betId, msg.sender, amount, rollUnder, betChoice, isBonus, note);   
        bets.push(Bet({
            rollUnder: uint8(rollUnder),
            choice: uint40(betChoice),
            outcome: 0,
            placeBlockNumber: uint168(block.number),
            amount: uint128(amount),
            winAmount: 0,
            player: msg.sender,
            isSettled: false
        }));
    }

    function settleBet(bytes32 requestId, uint256[] memory expandedValues) external isVRFManager {
        uint[] memory pendingBetIds = betMap[requestId];
        uint i;
        for (i = 0; i < pendingBetIds.length; i++) {
            // The VRFManager is optimized to prevent this from happening, this check is just to make sure that if it happens the tx will not be reverted, if this result is true the bet will be refunded manually later
            if (gasleft() <= 80000) {
                return;
            }
            // The pendingbets are always <= than the expandedValues
            _settleBet(pendingBetIds[i], expandedValues[i]);
        }
    }

    function _settleBet(uint betId, uint256 randomNumber) private nonReentrant {
        Bet storage bet = bets[betId];

        uint amount = bet.amount;
        if (amount == 0 || bet.isSettled == true) {
            return;
        }

        address player = bet.player;
        uint choice = bet.choice;
        uint rollUnder = bet.rollUnder;

        uint outcome = randomNumber % MODULO;
        uint winnableAmount = amountToWinnableAmount(amount, rollUnder);
        uint winAmount = (2 ** outcome) & choice != 0 ? winnableAmount : 0;

        bet.isSettled = true;
        bet.winAmount = uint128(winAmount);
        bet.outcome = uint40(outcome);

        house.settleBet(player, winnableAmount, winAmount > 0);
        emit BetSettled(betId, player, amount, rollUnder, choice, outcome, winAmount);
    }

    function refundBet(uint betId) external nonReentrant {
        require(gameIsLive, "Game is not live");
        Bet storage bet = bets[betId];
        uint amount = bet.amount;

        require(amount > 0, "Bet does not exist");
        require(bet.isSettled == false, "Bet is settled already");
        require(block.number > bet.placeBlockNumber + 21600, "Wait before requesting refund");

        uint winnableAmount = amountToWinnableAmount(amount, bet.rollUnder);
        uint bettedAmount = amountToBettableAmountConverter(amount);
        
        bet.isSettled = true;
        bet.winAmount = uint128(bettedAmount);

        house.refundBet(bet.player, bettedAmount, winnableAmount);
        emit BetRefunded(betId, bet.player, bettedAmount);
    }

    // Return the bet in extremely unlikely scenario it was not settled by Chainlink VRF V2. 
    // In case you ever find yourself in a situation like this, just contact NEON support Team.
    // However, nothing precludes you from calling this method yourself.
}