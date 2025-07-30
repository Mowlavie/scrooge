class User < ApplicationRecord
    has_one :account, dependent: :destroy
    has_many :loans, dependent: :destroy
    has_many :transactions, through: :account
    
    validates :email, presence: true, uniqueness: true
    validates :name, presence: true
    
    def active_account
      account&.active? ? account : nil
    end
  end