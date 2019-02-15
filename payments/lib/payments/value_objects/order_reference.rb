module Payments
  class OrderReference
    include Comparable

    def initialize(order_id)
      @order_id = order_id
    end

    def <=>(other)
      self.class == other.class && order_id == other.order_id ? 0 : -1
    end

    def to_s
      order_id
    end

    protected

    attr_reader :order_id
  end
end
