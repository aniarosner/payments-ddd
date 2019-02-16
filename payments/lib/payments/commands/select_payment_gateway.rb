module Payments
  class SelectPaymentGateway
    include Command
    attr_accessor :payment_id,
                  :payment_gateway

    def initialize(payment_id:, payment_gateway:)
      @payment_id = payment_id
      @payment_gateway = payment_gateway
    end
  end
end
