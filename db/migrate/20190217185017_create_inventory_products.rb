class CreateInventoryProducts < ActiveRecord::Migration[5.2]
  def change
    create_table :inventory_products, id: false do |t|
      t.uuid :product_id, primary_key: true, null: false, default: 'gen_random_uuid()'
      t.string :sku, null: false
      t.string :name, null: false
      t.integer :quantity, null: false
    end
  end
end
