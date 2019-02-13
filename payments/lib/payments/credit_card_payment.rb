module Payments
  class CreditCardPayment
    include AggregateRoot

    InvalidOperation = Class.new(StandardError)

    def initialize(payment_id)
      @payment_id         = payment_id
      @transaction_id     = nil
      @state              = :initialized
      @authorized_balance = 0
      @captured_balance   = 0
      @currency           = nil
    end

    def authorize_credit_card(credit_card:, amount:)
      raise Payments::InvalidOperation unless can_authorize?

      apply(PaymentAuthorized.new(data: {
        payment_id: @payment_id,
        credit_card: credit_card.token,
        amount: amount.value,
        currency: amount.currency,
        transaction_id: 'transaction_id' # TODO
      }))
    rescue # SomePaymentGatewayError
      apply(PaymentAuthorizationFailed.new(data: {
        payment_id: payment_id
      }))
    end

    def can_authorize?
      @state.in?(%i[initialized failed_authorization])
    end

    on Payments::PaymentAuthorized do |event|
      @state              = :authorized
      @authorized_balance = event.data[:amount]
      @currency           = event.data[:currency]
    end

    on Payments::PaymentAuthorized do |_event|
      @state = :failed_authorization
    end
  end
end
