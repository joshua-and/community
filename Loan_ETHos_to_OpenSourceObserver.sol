// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleLoanContract {
    // Address of the lender (ETHos)
    address public lender;

    // Address of the borrower (Open Source Observer)
    address payable public borrower;

    // Loan amount terms
    uint public loanAmount;

    // Repayment amount - could be different from loanAmount if interest were considered
    uint public repaymentAmount;

    // Deadline for repayment
    uint public repaymentDeadline;

    // Indicates if the loan is fully repaid
    bool public isLoanRepaid = false;

    // Constructor to set the lender, borrower, loan amount, and repayment deadline
    constructor(address payable _borrower, uint _loanAmount, uint _repaymentAmount, uint _repaymentDeadline) {
        lender = msg.sender;
        borrower = _borrower;
        loanAmount = _loanAmount;
        repaymentAmount = _repaymentAmount;
        repaymentDeadline = block.timestamp + _repaymentDeadline;
    }

    // Function for the borrower to accept the loan terms and receive the loan
    // For simplicity, we're assuming the loan amount is already sent to the contract
    function acceptLoanAndReceiveFunds() external {
        require(msg.sender == borrower, "Only the borrower can accept the loan");
        borrower.transfer(loanAmount);
    }

    // Function to allow the borrower to repay the loan
    function repayLoan() external payable {
        require(msg.sender == borrower, "Only the borrower can repay the loan");
        require(block.timestamp <= repaymentDeadline, "Cannot repay the loan after the deadline");
        require(msg.value == repaymentAmount, "Repayment amount must match the agreed amount");
        isLoanRepaid = true;
    }

    // Function for the lender to withdraw the repaid amount
    function withdrawRepayment() external {
        require(msg.sender == lender, "Only the lender can withdraw");
        require(isLoanRepaid, "The loan has not been repaid yet");
        payable(lender).transfer(address(this).balance);
    }
}
