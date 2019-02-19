module Fulfillment
  class Order
    include AggregateRoot

    AlreadyAccepted = Class.new(StandardError)

    def initialize(order_id)
      @order_id = order_id
      @state = Fulfillment::OrderState.new(:initialized)
    end

    def accept(order_lines)
      raise AlreadyAccepted if @state.accepted?

      apply(Fulfillment::OrderAccepted.new(data: {
        order_id: @order_id,
        order_lines: order_lines.map { |order_line| order_line.to_hash }
      }))
    end

    def reject(order_lines)
      raise AlreadyAccepted if @state.accepted?

      apply(Fulfillment::OrderRejected.new(data: {
        order_id: @order_id,
        order_lines: order_lines.map { |order_line| order_line.to_hash }
      }))
    end

    on Fulfillment::OrderAccepted do |_event|
      @state = Fulfillment::OrderState.new(:accepted)
    end

    on Fulfillment::OrderRejected do |_event|
      @state = Fulfillment::OrderState.new(:rejected)
    end
  end
end
