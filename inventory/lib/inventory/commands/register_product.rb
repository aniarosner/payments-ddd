module Inventory
  class RegiserProduct
    include Command
    attr_accessor :product_id,
                  :sku,
                  :name

    def initialize(product_id:, sku:, name:)
      @product_id = product_id
      @sku        = sku
      @name       = name
    end
  end
end
