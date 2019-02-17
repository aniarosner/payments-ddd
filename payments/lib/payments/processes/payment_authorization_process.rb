module Payments
  class PaymentAuthorizationProcess
    class State
      def initialize(event_store:, stream_name:)
        @event_store = event_store
        @stream_name = stream_name

        @order_state        = :unknown
        @order_id           = nil
        @payment_state      = :unknown
        @payment_id         = nil
        @order_fulfillment  = :unknown

        @version           = -1
        @event_ids_to_link = []
      end
    end

    attr_reader :payment_id

    def apply(event)
      case event
      when Orders::OrderSubmitted
        @order_id    = event.data[:order_id]
        @order_state = :submitted
      when Payments::PaymentAssignedToOrder
        @payment_id    = event.data[:payment_id]
        @payment_state = :assigned
      when Payments::CreditCardAuthorized
        @payment_state = :authorized
      when Payments::AuthorizationCaptured
        @payment_state = :captured
      when Payments::AuthorizationReleased
        @payment_state = :released
      when Fulfillment::OrderAccepted
        @fulfillment = :accepted
      when Fulfillment::OrderRejected
        @fulfillment = :rejected
      when Orders::OrderCancelled
        @order_state = :cancelled
      end

      @event_ids_to_link << event.event_id
    end

    def load
      event_store.read.stream(@stream_name).forward.each do |event|
        apply(event)
        @version += 1
      end

      @event_ids_to_link = []
    end

    def store
      @event_store.link(
        @event_ids_to_link,
        stream_name: @stream_name,
        expected_version: @version
      )

      @version += @event_ids_to_link.size
      @event_ids_to_link = []
    rescue RubyEventStore::WrongExpectedVersion
      retry
    end

    private

    def capture?
      accepted_fulfillment?
    end

    def release?
      rejected_fulfillment? || cancelled_order?
    end

    def accepted_fulfillment?
      @order_state == :submitted && @payment_state == :authorized && @fulfillment == :accepted
    end

    def rejected_fulfillment?
      @order_state == :submitted && @payment_state == :authorized && @fulfillment == :rejected
    end

    def cancelled_order?
      @order_state == :cancelled && @payment_state == :authorized
    end
  end

  private_constant :State

  def call(event)
    stream_name = "PaymentAuthorizationProcess$#{event.data[:order_id]}"

    state = State.new
    state.load(event_store: @event_store, stream_name: stream_name)
    state.apply(event)
    state.store(event_store: @event_store, stream_name: stream_name)

    @command_bus.call(Payments::CaptureAuthorization.new(payment_id: State.payment_id)) if capture?
    @command_bus.call(Payments::ReleaseAuthorization.new(payment_id: State.payment_id)) if release?
  end

  private

  def initialize(event_store: Rails.configuration.event_store, command_bus: Rails.configuration.command_bus)
    @event_store = event_store
    @command_bus = command_bus
  end
end
