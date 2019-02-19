module Inventory
  class SetProductQuantity
    include Command
    attr_accessor :product_id,
                  :quantity

    def initialize(product_id:, quantity:)
      validate_quantity_format(quantity) # TODO: create as a validate method

      @product_id = product_id
      @quantity   = quantity
    end

    private

    def validate_quantity_format(quantity)
      raise Inventory::InvalidQuantityFormat.new unless quantity.is_a?(Integer)
    end
  end
end
