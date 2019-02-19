module Orders
  class OrderLine
    def initialize(product_id:, sku:, quantity:, price:, currency:)
      @product_id = product_id
      @sku        = sku
      @quantity   = quantity
      @price      = price
      @currency   = currency
    end

    def <=>(other)
      self.class == other.class && product_id == other.product_id ? 0 : -1
    end

    def to_hash
      {
        product_id: product_id,
        sku: sku,
        quantity: quantity,
        price: price,
        currency: currency
      }
    end

    alias eql? ==

    attr_reader :product_id, :sku, :quantity, :price, :currency
  end
end
