class Loan < ApplicationRecord
  belongs_to :user
  
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :status, inclusion: { in: ['pending', 'approved', 'rejected', 'paid_off'] }
  validates :remaining_balance, presence: true, numericality: { greater_than_or_equal_to: 0 }
  
  before_validation :set_remaining_balance, on: :create
  
  scope :approved, -> { where(status: 'approved') }
  scope :active, -> { where(status: 'approved').where('remaining_balance > 0') }
  
  def approve!
    return false unless can_approve?
    
    transaction do
      update!(status: 'approved')
      user.active_account&.deposit!(amount, "Loan disbursement - Loan ##{id}")
      Bank.deduct_funds!(amount)
    end
    true
  end
  
  def reject!
    update!(status: 'rejected')
  end
  
  def make_payment!(payment_amount)
    return false if payment_amount <= 0 || payment_amount > remaining_balance
    return false unless user.active_account&.balance&.>= payment_amount
    
    transaction do
      user.active_account.withdraw!(payment_amount, "Loan payment - Loan ##{id}")
      Bank.add_funds!(payment_amount)
      decrement!(:remaining_balance, payment_amount)
      update!(status: 'paid_off') if remaining_balance.zero?
    end
    true
  end
  
  private
  
  def set_remaining_balance
    self.remaining_balance = amount if remaining_balance.nil?
  end
  
  def can_approve?
    status == 'pending' && Bank.can_cover_loan?(amount)
  end
end