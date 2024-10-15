// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "./IFSFIPool.sol";

/// @title FSFI pool contract
/// @author
/// @notice Link/usd
contract FSFIPool is IFSFIPool, Initializable {
    using WadRayMath for uint256;
    using PercentageMath for uint256;
    using SafeCast for uint256;

    mapping(address => bool) public operators;

    IERC20Standard public stableCoinAddress;
    address[] public lenders;

    mapping(uint => DataTypes.Loan) public loans;
    address public FSFI;

    // ray
    DataTypes.ReserveData public reserve;
    mapping(address => uint) public share;
    mapping(uint => uint) public debt;

    uint public totalSupply;
    uint public totalLiquidity;
    uint public totalDebt;

    uint public remainingPool;

    address public owner;
    bool public isPaused;

    mapping(address => uint) public depositWithdrawAmount;

    address public encryptus;

    uint public cap;
    modifier onlyFSFI() {
        require(FSFI == msg.sender, Errors.ONLY_THE_FSFI);
        _;
    }

    modifier onlyOperator() {
        require(operators[msg.sender] == true, Errors.ONLY_THE_OPERATOR);
        _;
    }

    modifier onlyOwner() {
        require(owner == msg.sender, Errors.ONLY_THE_OWNER);
        _;
    }

    modifier onlyUnpaused() {
        require(isPaused == false, Errors.SC_IS_PAUSED);
        _;
    }

    function setPaused(bool _paused) public onlyOwner {
        isPaused = _paused;
    }

    function initialize(
        IERC20Standard _stableCoinAddress,
        address _interestRateStrategyAddress,
        uint _cap,
        address _encryptus
    ) external initializer {
        stableCoinAddress = _stableCoinAddress;
        reserve.interestRateStrategyAddress = _interestRateStrategyAddress;
        reserve.liquidityIndex = uint128(WadRayMath.RAY);
        reserve.variableBorrowIndex = uint128(WadRayMath.RAY);
        owner = msg.sender;
        operators[msg.sender] = true;
        cap = _cap;
        encryptus = _encryptus;
    }

    function setOperators(
        address[] memory _addresses,
        bool[] memory _isActives
    ) public onlyOwner {
        for (uint i = 0; i < _addresses.length; i++) {
            operators[_addresses[i]] = _isActives[i];
        }
    }

    function setFSFI(address _fsfi) public onlyOperator {
        FSFI = _fsfi;
    }

    function setCap(uint _cap) public onlyOperator {
        cap = _cap;
    }

    function setEncryptus(address _encryptus) public onlyOperator {
        encryptus = _encryptus;
    }

    function setReserveInterestRateStrategy(
        address _interestRateStrategyAddress
    ) public onlyOperator {
        reserve.interestRateStrategyAddress = _interestRateStrategyAddress;
    }

    function getRemainingPool() public view returns (uint amount) {
        return remainingPool;
    }

    function getDebtPool() public view returns (uint amount) {
        DataTypes.ReserveCache memory reserveCache = cache();

        uint256 cumulatedVariableBorrowInterest = MathUtils
            .calculateCompoundedInterest(
                reserveCache.currVariableBorrowRate,
                reserveCache.reserveLastUpdateTimestamp
            );
        reserveCache.nextVariableBorrowIndex = cumulatedVariableBorrowInterest
            .rayMul(reserve.variableBorrowIndex);
        return
            (totalDebt.rayMul(reserveCache.nextVariableBorrowIndex) *
                (10 ** stableCoinAddress.decimals())) / uint128(WadRayMath.RAY);
    }

    receive() external payable {}

    function cache() internal view returns (DataTypes.ReserveCache memory) {
        DataTypes.ReserveCache memory reserveCache;

        reserveCache.currLiquidityIndex = reserveCache
            .nextLiquidityIndex = reserve.liquidityIndex;
        reserveCache.currVariableBorrowIndex = reserveCache
            .nextVariableBorrowIndex = reserve.variableBorrowIndex;
        reserveCache.currLiquidityRate = reserve.currentLiquidityRate;
        reserveCache.currVariableBorrowRate = reserve.currentVariableBorrowRate;

        reserveCache.reserveLastUpdateTimestamp = reserve.lastUpdateTimestamp;
        reserveCache.currScaledVariableDebt = totalDebt;

        return reserveCache;
    }

    function updateState(DataTypes.ReserveCache memory reserveCache) internal {
        // If time didn't pass since last stored timestamp, skip state update
        //solium-disable-next-line
        if (reserve.lastUpdateTimestamp == uint40(block.timestamp)) {
            return;
        }

        _updateIndexes(reserveCache);

        //solium-disable-next-line
        reserve.lastUpdateTimestamp = uint40(block.timestamp);
    }

    function _updateIndexes(
        DataTypes.ReserveCache memory reserveCache
    ) internal {
        // Only cumulating on the supply side if there is any income being produced
        // The case of Reserve Factor 100% is not a problem (currentLiquidityRate == 0),
        // as liquidity index should not be updated
        if (reserveCache.currLiquidityRate != 0) {
            uint256 cumulatedLiquidityInterest = MathUtils
                .calculateLinearInterest(
                    reserveCache.currLiquidityRate,
                    reserveCache.reserveLastUpdateTimestamp
                );
            reserveCache.nextLiquidityIndex = cumulatedLiquidityInterest.rayMul(
                reserveCache.currLiquidityIndex
            );
            reserve.liquidityIndex = reserveCache
                .nextLiquidityIndex
                .toUint128();
        }

        // Variable borrow index only gets updated if there is any variable debt.
        // reserveCache.currVariableBorrowRate != 0 is not a correct validation,
        // because a positive base variable rate can be stored on
        // reserveCache.currVariableBorrowRate, but the index should not increase
        if (reserveCache.currScaledVariableDebt != 0) {
            uint256 cumulatedVariableBorrowInterest = MathUtils
                .calculateCompoundedInterest(
                    reserveCache.currVariableBorrowRate,
                    reserveCache.reserveLastUpdateTimestamp
                );
            reserveCache
                .nextVariableBorrowIndex = cumulatedVariableBorrowInterest
                .rayMul(reserveCache.currVariableBorrowIndex);
            reserve.variableBorrowIndex = reserveCache
                .nextVariableBorrowIndex
                .toUint128();
        }
    }

    function updateInterestRates(
        uint256 liquidityAdded,
        uint256 liquidityTaken
    ) internal {
        DataTypes.UpdateInterestRatesLocalVars memory vars;
        (
            vars.nextLiquidityRate,
            vars.nextVariableRate
        ) = IReserveInterestRateStrategy(reserve.interestRateStrategyAddress)
            .calculateInterestRates(
                DataTypes.CalculateInterestRatesParams({
                    liquidityAdded: liquidityAdded,
                    liquidityTaken: liquidityTaken,
                    totalVariableDebt: totalDebt.rayMul(
                        reserve.variableBorrowIndex
                    ),
                    totalLiquidity: totalLiquidity.rayMul(
                        reserve.liquidityIndex
                    )
                })
            );

        reserve.currentLiquidityRate = vars.nextLiquidityRate.toUint128();
        reserve.currentVariableBorrowRate = vars.nextVariableRate.toUint128();
    }

    function supply(uint256 _amount) public onlyUnpaused {
        require(getTotalSupply() + _amount <= cap, Errors.OVER_CAP);
        DataTypes.ReserveCache memory reserveCache = cache();

        updateState(reserveCache);

        uint256 rayAmount = (_amount * uint128(WadRayMath.RAY)) /
            (10 ** stableCoinAddress.decimals());

        updateInterestRates(rayAmount, 0);

        uint256 amountScaled = rayAmount.rayDiv(reserve.liquidityIndex);

        uint256 total = share[msg.sender] + amountScaled;
        totalSupply += amountScaled;
        totalLiquidity += amountScaled;

        share[msg.sender] = total;
        remainingPool += _amount;
        stableCoinAddress.transferFrom(msg.sender, address(this), _amount);
        depositWithdrawAmount[msg.sender] += _amount;
        emit AddSupply(
            msg.sender,
            address(this),
            stableCoinAddress,
            _amount,
            share[msg.sender],
            totalSupply,
            totalLiquidity,
            remainingPool
        );
    }

    function balanceOf(address _user) public view returns (uint256) {
        return
            (share[_user].rayMul(reserve.liquidityIndex)) /
            (10 ** (27 - stableCoinAddress.decimals()));
    }

    function getDepositWithdrawAmount(
        address _user
    ) public view returns (uint256) {
        return depositWithdrawAmount[_user];
    }

    function withdraw(uint256 _amount) public onlyUnpaused {
        DataTypes.ReserveCache memory reserveCache = cache();

        updateState(reserveCache);

        uint256 rayAmount = (_amount * uint128(WadRayMath.RAY)) /
            (10 ** stableCoinAddress.decimals());

        updateInterestRates(0, rayAmount);

        uint256 amountScaled = rayAmount.rayDiv(reserve.liquidityIndex);

        uint256 total = share[msg.sender] - amountScaled;
        totalSupply -= amountScaled;
        totalLiquidity -= amountScaled;
        require(total >= 0, Errors.DO_NOT_HAVE_ENOUGH_LENDING_FUND);
        share[msg.sender] = total;
        remainingPool -= _amount;
        stableCoinAddress.transfer(msg.sender, _amount);

        uint256 totalUnscale = (total.rayMul(reserve.liquidityIndex) *
            (10 ** stableCoinAddress.decimals())) / uint128(WadRayMath.RAY);
        if (totalUnscale < depositWithdrawAmount[msg.sender])
            depositWithdrawAmount[msg.sender] = totalUnscale;

        emit WithdrawSupply(
            msg.sender,
            address(this),
            stableCoinAddress,
            _amount,
            share[msg.sender],
            totalSupply,
            totalLiquidity,
            remainingPool
        );
    }

    function borrow(
        uint _loanId,
        uint256 _amount,
        address _borrower,
        bool _isFiat
    ) public onlyFSFI onlyUnpaused {
        DataTypes.ReserveCache memory reserveCache = cache();
        updateState(reserveCache);

        uint256 rayAmount = (_amount * uint128(WadRayMath.RAY)) /
            (10 ** stableCoinAddress.decimals());

        uint256 amountScaled = rayAmount.rayDiv(
            reserveCache.nextVariableBorrowIndex
        );

        uint256 total = debt[_loanId] + amountScaled;
        totalDebt += amountScaled;

        require(_amount <= remainingPool, Errors.DO_NOT_HAVE_ENOUGH_LIQUIDITY);

        DataTypes.Loan storage loan = loans[_loanId];
        debt[_loanId] = total;
        loan.loanId = _loanId;
        loan.amount = _amount;
        loan.borrower = _borrower;
        loan.isFiat = _isFiat;

        updateInterestRates(0, rayAmount);
        totalLiquidity -= rayAmount.rayDiv(reserveCache.nextLiquidityIndex);
        remainingPool -= _amount;
        if (!_isFiat) {
            stableCoinAddress.transfer(_borrower, loan.amount);
        } else {
            stableCoinAddress.transfer(encryptus, loan.amount);
        }
    }

    function repay(uint _loanId, uint256 _amount) public onlyFSFI onlyUnpaused {
        require(loans[_loanId].isClosed == false, Errors.IT_IS_CLOSED);
        DataTypes.ReserveCache memory reserveCache = cache();

        updateState(reserveCache);

        uint256 rayAmount = (_amount * uint128(WadRayMath.RAY)) /
            (10 ** stableCoinAddress.decimals());

        uint256 amountScaled = rayAmount.rayDiv(reserve.variableBorrowIndex);

        if (debt[_loanId] <= amountScaled) {
            totalDebt -= debt[_loanId];
            uint256 amountPayScaled = debt[_loanId].rayMul(
                reserve.variableBorrowIndex
            );
            uint256 amountPayToken = (amountPayScaled *
                (10 ** stableCoinAddress.decimals())) / uint128(WadRayMath.RAY);
            debt[_loanId] = 0;
            updateInterestRates(amountPayScaled, 0);
            totalLiquidity += debt[_loanId].rayDiv(
                reserveCache.nextLiquidityIndex
            );
            remainingPool += amountPayToken;
            stableCoinAddress.transferFrom(FSFI, address(this), amountPayToken);
            loans[_loanId].isClosed = true;
        } else {
            uint256 total = debt[_loanId] - amountScaled;
            totalDebt -= amountScaled;

            debt[_loanId] = total;

            updateInterestRates(rayAmount, 0);
            totalLiquidity += rayAmount.rayDiv(reserveCache.nextLiquidityIndex);
            remainingPool += _amount;
            stableCoinAddress.transferFrom(FSFI, address(this), _amount);
        }
    }

    function liquidatePenalty(
        uint256 _loanId,
        uint256 _amount
    ) public onlyFSFI onlyUnpaused {
        require(loans[_loanId].isLiquidated == false, Errors.IT_IS_LIQUIDATED);
        addReward(_amount, msg.sender);
        loans[_loanId].isLiquidated = true;
    }

    function earnStaking(uint256 _amount) public onlyFSFI onlyUnpaused {
        addReward(_amount, msg.sender);
    }

    function addReward(uint256 _amount, address _sender) internal {
        if (_amount > 0) {
            DataTypes.ReserveCache memory reserveCache = cache();
            updateState(reserveCache);

            uint256 rayAmount = (_amount * uint128(WadRayMath.RAY)) /
                (10 ** stableCoinAddress.decimals());

            uint256 totalLiquidityScale = totalLiquidity.rayMul(
                reserveCache.nextLiquidityIndex
            );
            uint256 newLiquidityIndex = (totalLiquidityScale + rayAmount)
                .rayMul(reserveCache.nextLiquidityIndex)
                .rayDiv(totalLiquidityScale);

            reserve.liquidityIndex = newLiquidityIndex.toUint128();
            remainingPool += _amount;
            stableCoinAddress.transferFrom(_sender, address(this), _amount);
        }
    }

    function getCurrentLoan(uint _loanId) public view returns (uint256) {
        DataTypes.ReserveCache memory reserveCache = cache();

        uint256 cumulatedVariableBorrowInterest = MathUtils
            .calculateCompoundedInterest(
                reserveCache.currVariableBorrowRate,
                reserveCache.reserveLastUpdateTimestamp
            );
        reserveCache.nextVariableBorrowIndex = cumulatedVariableBorrowInterest
            .rayMul(reserve.variableBorrowIndex);
        return
            (debt[_loanId].rayMul(reserveCache.nextVariableBorrowIndex) *
                (10 ** stableCoinAddress.decimals())) / uint128(WadRayMath.RAY);
    }

    function getCurrentRate()
        public
        view
        returns (uint256, uint256, uint256, uint256)
    {
        return (
            reserve.currentVariableBorrowRate,
            reserve.currentLiquidityRate,
            reserve.variableBorrowIndex,
            reserve.liquidityIndex
        );
    }

    function getTotalSupply() public view returns (uint256) {
        DataTypes.ReserveCache memory reserveCache = cache();

        uint256 cumulatedLiquidityRate = MathUtils.calculateLinearInterest(
            reserveCache.currLiquidityRate,
            reserveCache.reserveLastUpdateTimestamp
        );
        reserveCache.nextLiquidityIndex = cumulatedLiquidityRate.rayMul(
            reserveCache.nextLiquidityIndex
        );
        return
            (totalSupply.rayMul(reserveCache.nextLiquidityIndex) *
                (10 ** stableCoinAddress.decimals())) / uint128(WadRayMath.RAY);
    }

    function withdrawByAdmin(
        IERC20Standard _token,
        address _receiver
    ) public onlyOwner {
        _token.transfer(_receiver, _token.balanceOf(address(this)));
    }
}
