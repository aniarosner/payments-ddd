module Payments
  class CreditCardPayment
    include AggregateRoot

    InvalidOperation = Class.new(StandardError)

    def initialize(payment_id)
      @payment_id       = payment_id
      @order_reference  = nil
      @transaction_id   = nil
      @payment_gateway  = nil
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

    def select_payment_gateway(payment_gateway:)
      return unless @state.valid_for_payment_gateway_setting?

      apply(Payments::PaymentGatewaySelected.new(data: {
        payment_id: @payment_id,
        payment_gateway: payment_gateway.to_sym
      }))
    end

    def charge_credit_card(credit_card:, amount:)
      raise Payments::InvalidOperation unless @state.valid_for_charge?
      raise Payments::PaymentGatewayNotSelected unless @payment_gateway.present?

      transaction_id = @payment_gateway.charge(credit_card: credit_card, amount: amount)

      apply(PaymentSucceded.new(data: {
        payment_id: @payment_id,
        credit_card: credit_card.token,
        amount: amount.value,
        currency: amount.currency,
        transaction_id: transaction_id
      }))
    rescue Payments::InvalidOperation, Payments::PaymentGatewayError
      apply(PaymentFailed.new(data: {
        payment_id: @payment_id
      }))
    end

    def authorize_credit_card(credit_card:, amount:)
      raise Payments::InvalidOperation unless @state.valid_for_authorization?
      raise Payments::PaymentGatewayNotSelected unless payment_gateway_selected?

      transaction_id = @payment_gateway.charge(credit_card: credit_card, amount: amount)

      apply(PaymentAuthorized.new(data: {
        payment_id: @payment_id,
        credit_card: credit_card.token,
        amount: amount.value,
        currency: amount.currency,
        transaction_id: transaction_id
      }))
    rescue Payments::InvalidOperation, Payments::PaymentGatewayError
      apply(PaymentAuthorizationFailed.new(data: {
        payment_id: @payment_id
      }))
    end

    # NOTE: capture whole amount
    def capture_authorization
      raise Payments::InvalidOperation unless @state.valid_for_capture?

      @payment_gateway.capture(transaction_id: @transaction_id, amount: @authorized)

      apply(AuthorizationCaptured.new(data: {
        payment_id: @payment_id
      }))
    rescue Payments::InvalidOperation, Payments::PaymentGatewayError
      apply(AuthorizationCaptureFailed.new(data: {
        payment_id: @payment_id
      }))
    end

    def release_authorization
      raise Payments::InvalidOperation unless @state.valid_for_release?

      @payment_gateway.release(transaction_id: @transaction_id)

      apply(AuthorizationReleased.new(data: {
        payment_id: @payment_id
      }))
    rescue Payments::InvalidOperation, Payments::PaymentGatewayError
      apply(AuthorizationReleaseFailed.new(data: {
        payment_id: @payment_id
      }))
    end

    # NOTE: refund whole amount
    def refund
      raise Payments::InvalidOperation unless @state.valid_for_refund?

      @payment_gateway.refund(transaction_id: @transaction_id, amount: @charged || @captured)

      apply(PaymentRefunded.new(data: {
        payment_id: @payment_id
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

    on Payments::PaymentGatewaySelected do |event|
      @payment_gateway = PaymentGateway.new(event.data[:payment_gateway])
    end

    on Payments::PaymentSucceded do |event|
      @state    = Payments::Payment.new(:charged)
      @charged  = Payments::Amount.new(event.data[:amount], event.data[:currency])
    end

    on Payments::PaymentFailed do |_event|
      @state = Payments::Payment.new(:failed_charge)
    end

    on Payments::PaymentAuthorized do |event|
      @state      = Payments::Payment.new(:authorized)
      @authorized = Payments::Amount.new(event.data[:amount], event.data[:currency])
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
      @state          = Payments::Payment.new(:refunded) # NOTE: can add :partially_refunded state
      @refund_balance = @captured_balance
    end

    on Payments::PaymentRefundFailed do |_event|
      @state = Payments::Payment.new(:failed_refund)
    end
  end
end
