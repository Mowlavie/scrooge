class BankController < ApplicationController
    def status
      render json: {
        total_funds: Bank.total_funds,
        customer_deposits: Account.active.sum(:balance),
        outstanding_loans: Loan.active.sum(:remaining_balance),
        total_customers: User.joins(:account).where(accounts: { status: 'active' }).count
      }
    end
  end