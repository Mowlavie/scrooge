class LoansController < ApplicationController
  before_action :require_user
  
  def index
    loans = current_user.loans.order(created_at: :desc)
    render json: loans
  end
  
  def create
    unless current_user.active_account
      render json: { error: 'Must have an active account to apply for loan' }, status: :unprocessable_entity
      return
    end
    
    loan = current_user.loans.build(loan_params.merge(status: 'pending'))
    loan.save!
    
    if loan.approve!
      render json: { 
        message: 'Loan approved and funds disbursed',
        loan: loan.reload 
      }, status: :created
    else
      loan.reject!
      render json: { 
        message: 'Loan rejected - insufficient bank funds',
        loan: loan.reload 
      }, status: :created
    end
  end
  
  def payment
    loan = current_user.loans.find(params[:id])
    amount = params[:amount].to_f
    
    if loan.make_payment!(amount)
      render json: { 
        message: 'Payment successful',
        remaining_balance: loan.reload.remaining_balance
      }
    else
      render json: { error: 'Payment failed - insufficient account balance or invalid amount' }, status: :unprocessable_entity
    end
  end
  
  private
  
  def loan_params
    params.require(:loan).permit(:amount)
  end
end