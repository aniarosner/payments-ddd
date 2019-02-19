module Fulfillment
  class InventoryReadModel
    def all
      Fulfillment::Inventory::Product.all
    end

    def product_quantity(product_id)
      Fulfillment::Inventory::Product.find_by(product_id: product_id).quantity
    end
  end
end
