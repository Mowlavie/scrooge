class Bank
    INITIAL_FUNDS = 250_000.0
    CUSTOMER_FUNDS_RATIO = 0.25
    
    def self.total_funds
      initial_funds + available_customer_funds - total_loans_outstanding
    end
    
    def self.can_cover_loan?(amount)
      total_funds >= amount
    end
    
    def self.add_funds!(amount)
      current_additional = additional_funds
      set_config('additional_funds', current_additional + amount)
    end
    
    def self.deduct_funds!(amount)
      current_additional = additional_funds
      set_config('additional_funds', current_additional - amount)
    end
    
    private
    
    def self.initial_funds
      INITIAL_FUNDS + additional_funds
    end
    
    def self.additional_funds
      config_value('additional_funds', 0.0)
    end
    
    def self.available_customer_funds
      total_customer_deposits * CUSTOMER_FUNDS_RATIO
    end
    
    def self.total_customer_deposits
      Account.active.sum(:balance)
    end
    
    def self.total_loans_outstanding
      Loan.active.sum(:remaining_balance)
    end
    
    def self.config_value(key, default = nil)
      config = BankConfig.find_by(key: key)
      config ? config.value.to_f : default
    end
    
    def self.set_config(key, value)
      config = BankConfig.find_or_initialize_by(key: key)
      config.value = value.to_s
      config.save!
    end
  end