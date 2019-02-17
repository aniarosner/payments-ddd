module Inventory
  class ProductCommandHandler
    def initialize
      @event_store = Rails.configuration.event_store
    end

    # TODO: error handling

    def register_product(cmd)
      Inventory::Product.create!(
        name: cmd.name,
        sku: cmd.sku
      )

      @event_store.publish(
        Inventory::ProductRegistered.new(data: {
          product_id: cmd.product_id,
          name: cmd.name,
          sku: cmd.sku
        }),
        stream_name: stream_name(cmd.product_id)
      )
    end

    def set_product_quantity(cmd)
      product = Inventory::Product.find(cmd.product_id)
      product.set_quantity(cmd.quantity)

      @event_store.publish(
        Inventory::ProductQuantitySet.new(data: {
          product_id: cmd.product_id,
          sku: product.sku,
          quantity: cmd.quantity
        }),
        stream_name: stream_name(cmd.product_id)
      )
    end

    def increase_product_quantity(cmd)
      product = Inventory::Product.find(cmd.product_id)
      product.increase_quantity(cmd.quantity)

      @event_store.publish(
        Inventory::ProductQuantitySet.new(data: {
          product_id: cmd.product_id,
          sku: product.sku,
          quantity: product.quantity
        }),
        stream_name: stream_name(cmd.product_id)
      )
    end

    def decrease_product_quantity(cmd)
      product = Inventory::Product.find(cmd.product_id)
      product.decrease_quantity(cmd.quantity)

      @event_store.publish(
        Inventory::ProductQuantitySet.new(data: {
          product_id: cmd.product_id,
          sku: product.sku,
          quantity: product.quantity
        }),
        stream_name: stream_name(cmd.product_id)
      )
    end

    private

    def stream_name(product_id)
      "Inventory::Product$#{product_id}"
    end
  end
end
