module Fulfillment
  class OrderCommandHandler
    def initialize
      @event_store = Rails.configuration.event_store
    end

    def accept_order(cmd)
      ActiveRecord::Base.transaction do
        with_order(cmd.order_id) do |order|
          order.accept
        end
      end
    end

    def reject_order(cmd)
      ActiveRecord::Base.transaction do
        with_order(cmd.order_id) do |order|
          order.reject
        end
      end
    end

    private

    def with_order(order_id)
      Orders::CreditCardPayment.new(order_id).tap do |order|
        load_credit_card_payment(order_id, order)
        yield order
        store_course(order)
      end
    end

    def load_credit_card_payment(order_id, order)
      order.load(stream_name(order_id), event_store: @event_store)
    end

    def store_credit_card_payment(order)
      order.store(event_store: @event_store)
    end

    def stream_name(order_id)
      "Fulfillment::Order$#{order_id}"
    end
  end
end
