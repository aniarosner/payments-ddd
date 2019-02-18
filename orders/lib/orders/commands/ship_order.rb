module Orders
  class ShipOrder
    include Command
    attr_accessor :order_id

    def initialize(order_id:)
      @order_id = order_id
    end
  end
end
