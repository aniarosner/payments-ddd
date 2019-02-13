module Payments
  class CreditCardPayment
    include AggregateRoot

    InvalidOperation = Class.new(StandardError)

    def initialize(payment_id)
      @payment_id         = payment_id
      @order_id           = nil
      @transaction_id     = nil
      @state              = :initialized
      @authorized_balance = 0
      @captured_balance   = 0
      @currency           = nil
    end

    def assign_to_order(order_id:)
      raise Payments::InvalidOperation unless can_assign?

      apply(Payments::PaymentAssignedToOrder.new(data: {
        payment_id: @payment_id,
        order_id: order_id
      }))
    rescue Payments::InvalidOperation
      apply(Payments::PaymentAssignmentFailed.new(data: {
        payment_id: @payment_id,
        order_id: order_id
      }))
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
    rescue Payments::InvalidOperation # SomePaymentGatewayError
      apply(PaymentAuthorizationFailed.new(data: {
        payment_id: @payment_id
      }))
    end

    def capture_authorization
      raise Payments::InvalidOperation unless can_capture?

      apply(AuthorizationCaptured.new(data: {
        payment_id: @payment_id
      }))
    rescue Payments::InvalidOperation # SomePaymentGatewayError
      apply(AuthorizationCaptureFailed.new(data: {
        payment_id: @payment_id
      }))
    end

    def can_assign?
      @state.in?(%i[initialized])
    end

    def can_authorize?
      @state.in?(%i[assigned_to_order failed_authorization])
    end

    def can_capture?
      @state.in?(%i[authorized failed_capture])
    end

    on Payments::PaymentAssignedToOrder do |event|
      @state    = :assigned_to_order
      @order_id = event.data[:order_id]
    end

    on Payments::PaymentAssignmentFailed do |event|
    end

    on Payments::PaymentAuthorized do |event|
      @state              = :authorized
      @authorized_balance = event.data[:amount]
      @currency           = event.data[:currency]
    end

    on Payments::PaymentAuthorizationFailed do |_event|
      @state = :failed_authorization
    end

    on Payments::AuthorizationCaptured do |_event|
      @state = :captured
    end

    on Payments::AuthorizationCaptureFailed do |_event|
      @state = :failed_capture
    end
  end
end
