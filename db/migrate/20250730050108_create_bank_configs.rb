class CreateBankConfigs < ActiveRecord::Migration[7.0]
  def change
    create_table :bank_configs do |t|
      t.string :key, null: false
      t.string :value, null: false
      t.timestamps
    end
    
    add_index :bank_configs, :key, unique: true
  end
end