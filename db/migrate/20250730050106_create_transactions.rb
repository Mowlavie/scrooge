class CreateTransactions < ActiveRecord::Migration[8.0]
  def change
    create_table :transactions do |t|
      t.references :account, null: false, foreign_key: true
      t.string :transaction_type, null: false
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.string :description
      t.string :reference_id
      t.timestamps
    end
    
    add_index :transactions, [:account_id, :created_at]
  end
end