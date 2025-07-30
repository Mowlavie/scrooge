class CreateAccounts < ActiveRecord::Migration[8.0]
  def change
    create_table :accounts do |t|
      t.references :user, null: false, foreign_key: true
      t.string :account_type, null: false, default: 'checking'
      t.decimal :balance, precision: 10, scale: 2, default: 0.0
      t.string :status, null: false, default: 'active'
      t.timestamps
    end
    
    add_index :accounts, [:user_id, :status]
  end
end