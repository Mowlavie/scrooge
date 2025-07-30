class AccountsController < ApplicationController
    before_action :require_user
    
    def create
      if current_user.active_account
        render json: { error: 'User already has an active account' }, status: :conflict
        return
      end
      
      account = current_user.build_account(
        account_type: 'checking',
        balance: 0,
        status: 'active'
      )
      account.save!
      
      render json: account, status: :created
    end
    
    def show
      account = current_user.active_account
      return not_found_response unless account
      
      render json: {
        id: account.id,
        balance: account.balance,
        account_type: account.account_type,
        status: account.status,
        recent_transactions: account.transactions.recent.limit(10)
      }
    end
    
    def destroy
      account = current_user.active_account
      return not_found_response unless account
      
      if account.balance > 0
        render json: { error: 'Cannot close account with positive balance' }, status: :conflict
        return
      end
      
      account.close!
      render json: { message: 'Account closed successfully' }
    end
    
    def deposit
      account = current_user.active_account
      return not_found_response unless account
      
      amount = params[:amount].to_f
      
      if account.deposit!(amount)
        render json: { 
          message: 'Deposit successful', 
          new_balance: account.reload.balance 
        }
      else
        render json: { error: 'Invalid deposit amount' }, status: :unprocessable_entity
      end
    end
    
    def withdraw
      account = current_user.active_account
      return not_found_response unless account
      
      amount = params[:amount].to_f
      
      if account.withdraw!(amount)
        render json: { 
          message: 'Withdrawal successful', 
          new_balance: account.reload.balance 
        }
      else
        render json: { error: 'Insufficient funds or invalid amount' }, status: :unprocessable_entity
      end
    end
    
    private
    
    def not_found_response
      render json: { error: 'No active account found' }, status: :not_found
    end
  end
  