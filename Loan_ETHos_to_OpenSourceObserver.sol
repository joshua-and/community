// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Interface for the Optimism RPGF contract to interact with future income
interface IRPGFContract {
    function getPendingPayment(address recipient) external view returns (uint256);
    function claimPayment(address recipient) external;
}

contract LoanContract {
    address payable public lender;
    address payable public borrower;
    IRPGFContract public rpgfContract;
    uint256 public loanAmount;
    uint256 public repaymentAmount;
    uint256 public loanDueDate;
    bool public loanRepaid = false;
    
    // Initialize the contract with the lender (ETHos), borrower (Open Source Observer),
    // RPGF contract address, loan amount, repayment amount, and loan duration in days.
    constructor(address payable _lender, address payable _borrower, address _rpgfContractAddress, uint256 _loanAmount, uint256 _repaymentAmount, uint256 _loanDurationDays) {
        lender = _lender;
        borrower = _borrower;
        rpgfContract = IRPGFContract(_rpgfContractAddress);
        loanAmount = _loanAmount;
        repaymentAmount = _repaymentAmount;
        loanDueDate = block.timestamp + (_loanDurationDays * 1 days);
    }

    // Allow the lender to fund the loan
    function fundLoan() external payable {
        require(msg.sender == lender, "Only the lender can fund the loan");
        require(msg.value == loanAmount, "Incorrect loan amount");
        
        borrower.transfer(msg.value);
    }

    // Allow the borrower to repay the loan
    function repayLoan() external payable {
        require(msg.sender == borrower, "Only the borrower can repay the loan");
        require(block.timestamp <= loanDueDate, "Loan repayment period has expired");
        require(msg.value == repaymentAmount, "Incorrect repayment amount");
        require(!loanRepaid, "Loan has already been repaid");

        lender.transfer(msg.value);
        loanRepaid = true;
    }

    // Allow the lender to claim the collateral (future income) if the loan is not repaid in time
    function claimCollateral() external {
        require(msg.sender == lender, "Only the lender can claim the collateral");
        require(block.timestamp > loanDueDate, "Loan repayment period has not expired");
        require(!loanRepaid, "Loan has already been repaid");

        uint256 pendingPayment = rpgfContract.getPendingPayment(borrower);
        require(pendingPayment > 0, "No pending RPGF payments for borrower");

        rpgfContract.claimPayment(borrower);
        
        // Assuming the RPGF contract sends the claimed payment to the borrower,
        // the lender would then need to have a way to retrieve these funds from the borrower.
        // This might require additional legal or off-chain arrangements, as direct transfer
        // to the lender could be complex without explicit borrower consent or predefined logic
        // in the RPGF contract for such scenarios.
    }
}
