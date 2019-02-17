class CreateUiLedgerOperations < ActiveRecord::Migration[5.2]
  create_table :ui_ledger_operations do |t|
      t.uuid :payment_id, null: false
      t.integer :amount, null: false
      t.currency :string, null: false
      t.string :transaction_identifier, null: false
      t.datetime :timestamp, null: false
    end
end
