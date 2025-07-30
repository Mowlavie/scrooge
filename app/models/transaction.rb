class Transaction < ApplicationRecord
  belongs_to :account
  
  validates :transaction_type, inclusion: { in: ['deposit', 'withdrawal', 'loan_disbursement', 'loan_payment'] }
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :description, presence: true
  
  scope :deposits, -> { where(transaction_type: 'deposit') }
  scope :withdrawals, -> { where(transaction_type: 'withdrawal') }
  scope :recent, -> { order(created_at: :desc) }
end