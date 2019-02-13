module Payments
  class AssignPaymentToOrder
    include Command

    attr_accessor :payment_id,
                  :order_id

    def initialize(payment_id:, order_id:)
      @payment_id = payment_id
      @order_id   = order_id
    end
  end
end
