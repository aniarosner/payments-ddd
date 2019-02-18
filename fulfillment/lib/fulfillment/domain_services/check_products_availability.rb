module Fulfillment
  class CheckProductsAvailability
    def call(order_lines)
      order_lines.all? { |order_line| check_product_availability(order_line) }
    end

    private

    def check_product_availability(order_line)
      inventory_quantity = Fulfillment::InventoryReadModel.new.product_quantity(order_line.product_id)

      inventory_quantity >= order_line.quantity
    end
  end
end
