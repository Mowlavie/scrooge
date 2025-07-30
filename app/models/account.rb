class Account < ApplicationRecord
  belongs_to :user
  has_many :transactions, dependent: :destroy
  
  validates :account_type, inclusion: { in: ['checking'] }
  validates :status, inclusion: { in: ['active', 'closed'] }
  validates :balance, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :user_id, uniqueness: { scope: :status, conditions: -> { where(status: 'active') } }
  
  scope :active, -> { where(status: 'active') }
  scope :closed, -> { where(status: 'closed') }
  
  def active?
    status == 'active'
  end
  
  def close!
    return false if balance > 0
    update!(status: 'closed')
  end
  
  def deposit!(amount, description = 'Deposit')
    return false if amount <= 0
    
    transaction do
      increment!(:balance, amount)
      transactions.create!(
        transaction_type: 'deposit',
        amount: amount,
        description: description
      )
    end
    true
  end
  
  def withdraw!(amount, description = 'Withdrawal')
    return false if amount <= 0 || amount > balance
    
    transaction do
      decrement!(:balance, amount)
      transactions.create!(
        transaction_type: 'withdrawal',
        amount: amount,
        description: description
      )
    end
    true
  end
end