module Fulfillment
  module Inventory
    class OnProductQuantitySet
      def call(event)
        product = Fulfillment::Inventory::Product.find(event.data[:product_id])
        product.update(quantity: event.data[:quantity])
      end
    end
  end
end
