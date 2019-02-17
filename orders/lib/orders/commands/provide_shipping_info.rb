module Orders
  class ProvideShippingInfo
    include Command
    attr_accessor :order_id,
                  :receiver_name,
                  :shipping_address

    def initialize(order_id:, receiver_name:, shipping_address:)
      @order_id         = order_id
      @receiver_name    = receiver_name
      @shipping_address = shipping_address
    end
  end
end
