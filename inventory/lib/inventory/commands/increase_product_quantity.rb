module Inventory
  class IncreaseProductQuantity
    include Command
    attr_accessor :product_id,
                  :quantity

    def initialize(product_id:, quantity:)
      @product_id = product_id
      @quantity   = quantity
    end
  end
end
