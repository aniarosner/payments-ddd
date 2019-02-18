module Inventory
  class IncreaseProductQuantity
    include Command
    attr_accessor :product_id,
                  :quantity

    def initialize(product_id:, quantity:)
      @product_id = product_id
      @quantity   = quantity
    end

    private

    def quantity_format_validation
      raise Inventory::InvalidQuantityFormat.new unless quantity.is_a?(Integer)
    end
  end
end
