module Inventory
  class Product < ApplicationRecord
    self.table_name = 'inventory_products'
    validates :quantity, numericality: { greater_than_or_equal_to: 0 }

    def set_quantity(value)
      self.quantity = value
      save
    end

    def increase_quantity(value)
      self.quantity = quantity + value
      save
    end

    def decrease_quantity(value)
      self.quantity = quantity - value
      save
    end
  end
end
