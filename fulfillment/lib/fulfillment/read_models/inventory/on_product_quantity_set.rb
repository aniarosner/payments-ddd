module Fulfillment
  module Inventory
    class OnProductQuantitySet
      def call(event)
        product = Fulfillment::Inventory::Product.find_by(product_id: event.data[:product_id])
        product.update(quantity: event.data[:quantity])
      end
    end
  end
end
