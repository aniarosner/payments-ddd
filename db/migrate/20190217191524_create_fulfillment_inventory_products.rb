class CreateFulfillmentInventoryProducts < ActiveRecord::Migration[5.2]
  def change
    create_table :fulfillment_inventory_products do |t|
      t.uuid :product_id, null: false
      t.string :name, null: false
      t.string :sku, null: false
      t.integer :quantity, null: false
    end
  end
end
