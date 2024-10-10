// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

// Uncomment this line to use console.log
import "hardhat/console.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";

import "./IFSFIPool.sol";
import "./IFSFILoan.sol";
import "./IFSFIConfig.sol";

/// @title IFSFI contract
/// @author
/// @notice Link/usd
interface IFSFI {
    event CreateLoan(
        address indexed borrower,
        address loanAddress,
        DataTypes.Loan loanInfo,
        uint collateralAmount,
        IERC20Standard collateral,
        bool isYieldGenerating,
        bool isETH
    );

    event AddCollateral(
        address indexed borrower,
        DataTypes.Loan loanInfo,
        uint collateralAmount,
        IERC20Standard collateral,
        bool isETH
    );

    event RepayLoan(
        address indexed borrower,
        DataTypes.Loan loanInfo,
        uint repayAmount,
        uint debtRemain
    );

    event WithdrawAllCollateral(
        address indexed borrower,
        DataTypes.Loan loanInfo,
        uint collateralAmount,
        IERC20Standard collateral,
        bool isETH
    );

    event WithdrawAllCollateralByAdmin(
        address indexed admin,
        DataTypes.Loan loanInfo,
        uint collateralAmount,
        IERC20Standard collateral,
        bool isETH
    );

    event Liquidate(
        address indexed liquidator,
        address indexed borrower,
        DataTypes.Loan loanInfo,
        uint collateralAmount,
        IERC20Standard collateral
    );

    function initialize(
        IERC20Standard[] memory _fsfilPoolStableCoin,
        IFSFIPool[] memory _fsfilPools,
        IFSFIConfig _fsfilConfig,
        IFSFILoan _fsfilLoan
    ) external;

    function setPools(
        IERC20Standard[] memory _fsfilPoolStableCoin,
        IFSFIPool[] memory _fsfilPools
    ) external;

    // create loan
    function createLoan(
        uint _amount,
        IERC20Standard _stableCoin,
        uint _amountCollateral,
        IERC20Standard _collateral,
        bool _isYieldGenerating,
        bool _isFiat
    ) external;

    // repay loan
    function repayLoan(
        uint _loanId,
        uint _amount,
        IERC20Standard _stableCoin
    ) external;

    function getHealthFactor(uint _loanId) external view returns (uint);

    function getLoanAddress(uint _loanId) external view returns (address);

    function liquidate(uint _loanId) external;

    function addCollateral(
        uint _loanId,
        uint _amountCollateral,
        IERC20Standard _collateral
    ) external;

    function addCollateralByETH(uint _loanId, uint _amountETH) external payable;

    function checkMinimalCollateralForLoan(
        uint _amount,
        IERC20Standard _stableCoin,
        IERC20Standard _collateral
    ) external view returns (uint);

    function withdrawAllCollateral(uint _loanId, bool isETH) external;

    function addCollateralHealthFactor(
        uint _loanId,
        uint _amountCollateral
    ) external view returns (uint);

    function repayHealthFactor(
        uint _loanId,
        uint _amount
    ) external view returns (uint);

    function getLoanIds(address borrower) external view returns (uint[] memory);

    function createLoanByETH(
        uint _amount,
        IERC20Standard _stableCoin,
        uint _amountETH,
        bool _isYieldGenerating,
        bool _isFiat
    ) external payable;

    function estimateHealthFactor(
        IERC20Standard _stableCoin,
        uint _amount,
        IERC20Standard _collateralToken,
        uint _amountCollateral
    ) external view returns (uint);
}
