module Payments
  class CreditCardPayment
    include AggregateRoot

    InvalidOperation = Class.new(StandardError)

    def initialize(payment_id)
      @payment_id       = payment_id
      @order_reference  = nil
      @transaction      = nil
      @state            = Payments::PaymentState.new(:initialized)
      @authorized       = nil
      @captured         = nil
      @charged          = nil
      @refunded         = nil
    end

    def assign_to_order(order_reference:)
      raise InvalidOperation unless @state.valid_for_assignment?

      apply(Payments::PaymentAssignedToOrder.new(data: {
        payment_id: @payment_id,
        order_id: order_reference.to_s
      }))
    rescue InvalidOperation
      apply(Payments::PaymentAssignmentFailed.new(data: {
        payment_id: @payment_id,
        order_id: order_reference.to_s
      }))
    end

    def charge_credit_card(credit_card:, amount:, payment_gateway:)
      raise InvalidOperation unless @state.valid_for_charge?

      transaction = payment_gateway.charge(credit_card: credit_card, amount: amount)

      apply(Payments::PaymentSucceded.new(data: {
        payment_id: @payment_id,
        order_id: @order_reference.to_s,
        amount: amount.to_i,
        currency: amount.currency_code,
        transaction_identifier: transaction.identifier
      }))
    rescue InvalidOperation, Payments::PaymentGatewayError
      apply(Payments::PaymentFailed.new(data: {
        payment_id: @payment_id,
        order_id: @order_reference.to_s
      }))
    end

    def authorize_credit_card(credit_card:, amount:, payment_gateway:)
      raise InvalidOperation unless @state.valid_for_authorization?

      transaction = payment_gateway.authorize(credit_card: credit_card, amount: amount)

      apply(Payments::CreditCardAuthorized.new(data: {
        payment_id: @payment_id,
        order_id: @order_reference.to_s,
        amount: amount.to_i,
        currency: amount.currency_code,
        transaction_identifier: transaction.identifier
      }))
    rescue InvalidOperation, Payments::PaymentGatewayError
      apply(Payments::CreditCardAuthorizationFailed.new(data: {
        payment_id: @payment_id,
        order_id: @order_reference.to_s
      }))
    end

    # NOTE: capture whole amount
    def capture_authorization(payment_gateway:)
      raise InvalidOperation unless @state.valid_for_capture?

      payment_gateway.capture(transaction: @transaction, amount: @authorized)

      apply(Payments::AuthorizationCaptured.new(data: {
        payment_id: @payment_id,
        order_id: @order_reference.to_s,
        amount: @authorized.to_i,
        currency: @authorized.currency_code,
        transaction_identifier: @transaction.identifier
      }))
    rescue InvalidOperation, Payments::PaymentGatewayError
      apply(Payments::AuthorizationCaptureFailed.new(data: {
        payment_id: @payment_id,
        order_id: @order_reference.to_s
      }))
    end

    def release_authorization(payment_gateway:)
      raise InvalidOperation unless @state.valid_for_release?

      payment_gateway.release(transaction: @transaction)

      apply(Payments::AuthorizationReleased.new(data: {
        payment_id: @payment_id,
        order_id: @order_reference.to_s
      }))
    rescue InvalidOperation, Payments::PaymentGatewayError
      apply(Payments::AuthorizationReleaseFailed.new(data: {
        payment_id: @payment_id,
        order_id: @order_reference.to_s
      }))
    end

    # NOTE: refund whole amount
    def refund(payment_gateway:)
      raise InvalidOperation unless @state.valid_for_refund?

      amount = @charged || @captured
      payment_gateway.refund(transaction: @transaction, amount: amount)

      apply(Payments::PaymentRefunded.new(data: {
        payment_id: @payment_id,
        order_id: @order_reference.to_s,
        amount: amount.to_i,
        currency: amount.currency_code,
        transaction_identifier: @transaction.identifier
      }))
    rescue InvalidOperation, Payments::PaymentGatewayError
      apply(Payments::PaymentRefundFailed.new(data: {
        payment_id: @payment_id,
        order_id: @order_reference.to_s
      }))
    end

    on Payments::PaymentAssignedToOrder do |event|
      @state            = Payments::PaymentState.new(:assigned_to_order)
      @order_reference  = OrderReference.new(event.data[:order_id])
    end

    on Payments::PaymentAssignmentFailed do |_event|
    end

    on Payments::PaymentSucceded do |event|
      @state        = Payments::PaymentState.new(:charged)
      @charged      = Payments::Amount.new(event.data[:amount], event.data[:currency])
      @transaction  = Payments::Transaction.new(event.data[:transaction_identifier])
    end

    on Payments::PaymentFailed do |_event|
      @state = Payments::PaymentState.new(:failed_charge)
    end

    on Payments::CreditCardAuthorized do |event|
      @state        = Payments::PaymentState.new(:authorized)
      @authorized   = Payments::Amount.new(event.data[:amount], event.data[:currency])
      @transaction  = Payments::Transaction.new(event.data[:transaction_identifier])
    end

    on Payments::CreditCardAuthorizationFailed do |_event|
      @state = Payments::PaymentState.new(:failed_authorization)
    end

    on Payments::AuthorizationCaptured do |_event|
      @state            = Payments::PaymentState.new(:captured)
      @captured_balance = @authorized_balance
    end

    on Payments::AuthorizationCaptureFailed do |_event|
      @state = Payments::PaymentState.new(:failed_capture)
    end

    on Payments::AuthorizationReleased do |_event|
      @state = Payments::PaymentState.new(:released)
    end

    on Payments::AuthorizationReleaseFailed do |_event|
      @state = Payments::PaymentState.new(:failed_release)
    end

    on Payments::PaymentRefunded do |_event|
      @state          = Payments::PaymentState.new(:refunded)
      @refund_balance = @captured_balance
    end

    on Payments::PaymentRefundFailed do |_event|
      @state = Payments::PaymentState.new(:failed_refund)
    end
  end
end
