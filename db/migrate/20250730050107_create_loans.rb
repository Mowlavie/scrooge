class CreateLoans < ActiveRecord::Migration[8.0]
  def change
    create_table :loans do |t|
      t.references :user, null: false, foreign_key: true
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.string :status, null: false, default: 'pending'
      t.decimal :remaining_balance, precision: 10, scale: 2, default: 0.0
      t.timestamps
    end
    
    add_index :loans, [:user_id, :status]
  end
end