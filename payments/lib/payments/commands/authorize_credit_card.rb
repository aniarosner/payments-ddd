module Payments
  class AuthorizeCreditCard
    include Command
    attr_accessor :payment_id,
                  :credit_card_token,
                  :amount,
                  :currency

    def initialize(payment_id:, credit_card_token:, amount:, currency:)
      @payment_id         = payment_id
      @credit_card_token  = credit_card_token
      @amount             = amount
      @currency           = currency
    end
  end
end
