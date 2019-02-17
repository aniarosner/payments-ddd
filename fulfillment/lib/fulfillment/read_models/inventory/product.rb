module Fulfillment
  module Inventory
    class Product < ActiveRecord::Base
      self.table_name = 'fulfillment_inventory_products'
    end
  end
end
