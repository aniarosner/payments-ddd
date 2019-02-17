module Fulfillment
  module Inventory
    class OnProductRegistered
      def call(event)
        Fulfillment::Inventory::Product.create!(
          product_id: event.data[:product_id],
          sku: event.data[:sku],
          name: event.data[:name],
          quantity: event.data[:quantity]
        )
      end
    end
  end
end
