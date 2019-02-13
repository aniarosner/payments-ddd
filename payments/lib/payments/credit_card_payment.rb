module Payments
  class CreditCardPayment
    include AggregateRoot

    InvalidOperation = Class.new(StandardError)

    def initialize(payment_id)
      @payment_id = payment_id
      @transaction_id = transaction_id
      @state = :initialized
    end

    def authorize_credit_card
      apply(PaymentAuthorized.new(data: {}))
    rescue
      apply(PaymentAuthorizationFailed.new(data: {}))
    end
  end
end
