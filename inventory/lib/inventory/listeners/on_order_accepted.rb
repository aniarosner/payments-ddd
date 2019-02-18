module Inventory
  class OnOrderAccepted
    def initialize(command_bus: Rails.configuration.command_bus)
      @command_bus = command_bus
    end

    def call(event)
      parse_order_lines_from_event(event.data[:order_lines]).each do |order_line|
        @command_bus.call(
          Inventory::DecreaseProductQuantity.new(product_id: order_line.product, quantity: order_line.quantity)
        )
      end
    end

    def parse_order_lines_from_event(order_lines_from_event)
      order_lines_from_event.each do |order_line|
        Inventory::OrderLine.new(
          product_id: order_line[:product_id], sku: order_line[:sku], quantity: order_line[:quantity]
        )
      end
    end
  end
end
