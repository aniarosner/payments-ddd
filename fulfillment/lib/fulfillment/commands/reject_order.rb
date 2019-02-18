module Fulfillment
  class RejectOrder
    include Command
    attr_accessor :order_id,
                  :order_lines

    def initialize(order_id:, order_lines:)
      @order_id = order_id
      @order_lines = order_lines
    end
  end
end
