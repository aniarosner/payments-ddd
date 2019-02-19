module Orders
  class OrderShippingProcess
    class State
      def initialize
        @order_state        = :unknown
        @order_id           = nil
        @payment_state      = :unknown
        @order_fulfillment  = :unknown

        @version           = -1
        @event_ids_to_link = []
      end

      def apply(event)
        case event
        when Orders::OrderSubmitted
          @order_id    = event.data[:order_id]
          @order_state = :submitted
        when Orders::OrderShipped
          @order_state = :shipped
        when Payments::PaymentAssignedToOrder
          @payment_state = :assigned
        when Payments::CreditCardAuthorized
          @payment_state = :authorized
        when Fulfillment::OrderAccepted
          @fulfillment = :accepted
        when Fulfillment::OrderRejected
          @fulfillment = :rejected
        when Orders::OrderCancelled
          @order_state = :cancelled
        end

        @event_ids_to_link << event.event_id
      end

      def load(event_store:, stream_name:)
        event_store.read.stream(stream_name).forward.each do |event|
          apply(event)
          @version += 1
        end

        @event_ids_to_link = []
      end

      def store(event_store:, stream_name:)
        event_store.link(
          @event_ids_to_link,
          stream_name: stream_name,
          expected_version: @version
        )

        @version += @event_ids_to_link.size
        @event_ids_to_link = []
      rescue RubyEventStore::WrongExpectedVersion
        retry
      end

      def ship?
        @order_state == :submitted && @payment_state == :authorized && @fulfillment == :accepted
      end
    end

    private_constant :State

    def call(event)
      stream_name = "OrderShippingProcess$#{event.data[:order_id]}"

      state = State.new
      state.load(event_store: @event_store, stream_name: stream_name)
      state.apply(event)
      state.store(event_store: @event_store, stream_name: stream_name)

      @command_bus.call(Orders::ShipOrder.new(order_id: event.data[:order_id])) if state.ship?
    end

    private

    def initialize(event_store: Rails.configuration.event_store, command_bus: Rails.configuration.command_bus)
      @event_store = event_store
      @command_bus = command_bus
    end
  end
end
