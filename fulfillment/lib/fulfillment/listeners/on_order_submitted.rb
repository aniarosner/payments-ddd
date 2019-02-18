module Fulfillment
  class OnOrderSubmitted
    def initialize(command_bus: Rails.configuration.command_bus)
      @command_bus = command_bus
    end

    def call(event)
      order_lines = parse_order_lines_from_event(event.data[:order_lines])

      if all_products_available?(order_lines)
        @command_bus.call(Fulfillment::AcceptOrder.new(order_id: event.data[:order_id], order_lines: order_lines))
      else
        @command_bus.call(Fulfillment::RejectOrder.new(order_id: event.data[:order_id], order_lines: order_lines))
      end
    end

    private

    def parse_order_lines_from_event(order_lines_from_event)
      order_lines_from_event.map do |order_line|
        Fulfillment::OrderLine.new(
          product_id: order_line[:product_id], sku: order_line[:sku], quantity: order_line[:quantity]
        )
      end
    end

    def all_products_available?(order_lines)
      Fulfillment::CheckProductsAvailability.new.call(order_lines)
    end
  end
end
