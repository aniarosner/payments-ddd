module Fulfillment
  class OrderLine
    def initialize(product_id:, sku:, quantity:)
      @product_id = product_id
      @sku        = sku
      @quantity   = quantity
    end

    def <=>(other)
      self.class == other.class && product_id == other.product_id ? 0 : -1
    end

    def to_hash
      {
        product_id: product_id,
        sku: sku,
        quantity: quantity
      }
    end

    alias eql? ==

    attr_reader :product_id, :sku, :quantity
  end
end
