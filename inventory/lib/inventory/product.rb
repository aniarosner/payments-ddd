module Inventory
  class Product < ApplicationRecord
    validates :quantity, numericality: { greater_than_or_equal_to: 0 }

    def set_quantity(value)
      self.quantity = value
    end

    def increase_quantity(value)
      self.quantity += value
    end

    def decrease_quantity(value)
      self.quantity -= value
    end
  end
end
