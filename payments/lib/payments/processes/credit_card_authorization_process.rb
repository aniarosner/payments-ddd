module Payments
  class CreditCardAuthorizationProcess
    class State
      def initialize(event_store:, stream_name:)
        @event_store = event_store
        @stream_name = stream_name

        @order_state        = :unknown
        @order_id           = nil
        @payment_state      = :unknown
        @payment_id         = nil

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
      when Orders::OrderShipped
        @order_state = :shipped
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

    def capture?
      order_shipped? && credit_card_authorized?
    end

    def release?
      order_cancelled? && credit_card_authorized?
    end

    private

    def order_shipped?
      @order_state == :shipped
    end

    def credit_card_authorized?
      @payment_state == :authorized
    end

    def order_cancelled?
      @order_state == :cancelled
    end
  end

  private_constant :State

  def call(event)
    stream_name = "CreditCardAuthorizationProcess$#{event.data[:order_id]}"

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
