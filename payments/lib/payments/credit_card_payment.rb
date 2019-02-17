module Payments
  class CreditCardPayment
    include AggregateRoot

    InvalidOperation = Class.new(StandardError)

    def initialize(payment_id)
      @payment_id       = payment_id
      @order_reference  = nil
      @transaction      = nil
      @state            = :initialized
      @authorized       = nil
      @captured         = nil
      @charged          = nil
      @refunded         = nil
    end

    def assign_to_order(order_reference:)
      raise Payments::InvalidOperation unless @state.valid_for_assignment?

      apply(Payments::PaymentAssignedToOrder.new(data: {
        payment_id: @payment_id,
        order_id: order_reference.to_s
      }))
    rescue Payments::InvalidOperation
      apply(Payments::PaymentAssignmentFailed.new(data: {
        payment_id: @payment_id,
        order_id: order_reference.to_s
      }))
    end

    def charge_credit_card(credit_card:, amount:, payment_gateway:)
      raise Payments::InvalidOperation unless @state.valid_for_charge?

      transaction = payment_gateway.charge(credit_card: credit_card, amount: amount)

      apply(PaymentSucceded.new(data: {
        payment_id: @payment_id,
        amount: amount.value,
        currency: amount.currency,
        transaction_identifier: transaction.identifier
      }))
    rescue Payments::InvalidOperation, Payments::PaymentGatewayError
      apply(PaymentFailed.new(data: {
        payment_id: @payment_id
      }))
    end

    def authorize_credit_card(credit_card:, amount:, payment_gateway:)
      raise Payments::InvalidOperation unless @state.valid_for_authorization?

      transaction = payment_gateway.charge(credit_card: credit_card, amount: amount)

      apply(PaymentAuthorized.new(data: {
        payment_id: @payment_id,
        amount: amount.value,
        currency: amount.currency,
        transaction_identifier: transaction.identifier
      }))
    rescue Payments::InvalidOperation, Payments::PaymentGatewayError
      apply(PaymentAuthorizationFailed.new(data: {
        payment_id: @payment_id
      }))
    end

    # NOTE: capture whole amount
    def capture_authorization(payment_gateway:)
      raise Payments::InvalidOperation unless @state.valid_for_capture?

      payment_gateway.capture(transaction: @transaction, amount: @authorized)

      apply(AuthorizationCaptured.new(data: {
        payment_id: @payment_id,
        amount: @authorized.value,
        currency: @authorized.currency,
        transaction_identifier: @transaction.identifier
      }))
    rescue Payments::InvalidOperation, Payments::PaymentGatewayError
      apply(AuthorizationCaptureFailed.new(data: {
        payment_id: @payment_id
      }))
    end

    def release_authorization(payment_gateway:)
      raise Payments::InvalidOperation unless @state.valid_for_release?

      payment_gateway.release(transaction: @transaction)

      apply(AuthorizationReleased.new(data: {
        payment_id: @payment_id
      }))
    rescue Payments::InvalidOperation, Payments::PaymentGatewayError
      apply(AuthorizationReleaseFailed.new(data: {
        payment_id: @payment_id
      }))
    end

    # NOTE: refund whole amount
    def refund(payment_gateway:)
      raise Payments::InvalidOperation unless @state.valid_for_refund?

      amount = @charged || @captured
      payment_gateway.refund(transaction: @transaction, amount: amount)

      apply(PaymentRefunded.new(data: {
        payment_id: @payment_id,
        amount: amount.value,
        currency: amount.currency,
        transaction_identifier: @transaction.identifier
      }))
    rescue Payments::InvalidOperation, Payments::PaymentGatewayError
      apply(PaymentRefundFailed.new(data: {
        payment_id: @payment_id
      }))
    end

    on Payments::PaymentAssignedToOrder do |event|
      @state            = Payments::Payment.new(:assigned_to_order)
      @order_reference  = OrderReference.new(event.data[:order_id])
    end

    on Payments::PaymentAssignmentFailed do |_event|
    end

    on Payments::PaymentSucceded do |event|
      @state        = Payments::Payment.new(:charged)
      @charged      = Payments::Amount.new(event.data[:amount], event.data[:currency])
      @transaction  = Payments::Transaction.new(event.data[:transaction_identifier])
    end

    on Payments::PaymentFailed do |_event|
      @state = Payments::Payment.new(:failed_charge)
    end

    on Payments::PaymentAuthorized do |event|
      @state        = Payments::Payment.new(:authorized)
      @authorized   = Payments::Amount.new(event.data[:amount], event.data[:currency])
      @transaction  = Payments::Transaction.new(event.data[:transaction_identifier])
    end

    on Payments::PaymentAuthorizationFailed do |_event|
      @state = Payments::Payment.new(:failed_authorization)
    end

    on Payments::AuthorizationCaptured do |_event|
      @state            = Payments::Payment.new(:captured)
      @captured_balance = @authorized_balance
    end

    on Payments::AuthorizationCaptureFailed do |_event|
      @state = Payments::Payment.new(:failed_capture)
    end

    on Payments::AuthorizationReleased do |_event|
      @state = Payments::Payment.new(:released)
    end

    on Payments::AuthorizationReleaseFailed do |_event|
      @state = Payments::Payment.new(:failed_release)
    end

    on Payments::PaymentRefunded do |_event|
      @state          = Payments::Payment.new(:refunded)
      @refund_balance = @captured_balance
    end

    on Payments::PaymentRefundFailed do |_event|
      @state = Payments::Payment.new(:failed_refund)
    end
  end
end
