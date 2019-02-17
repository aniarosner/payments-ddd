module Orders
  class Order
    include AggregateRoot

    InvalidOperation = Class.new(StandardError)

    def initialize(order_id)
      @order_id       = order_id
      @order_state    = Orders::OrderState.new(:initialized)
      @shipping_info  = nil
      @contact_info   = nil
    end

    def place
      raise Orders::InvalidOperation unless @state.valid_for_place?

      apply(Orders::OrderPlaced.new(data: {
        order_id: @order_id
      }))
    end

    def provide_shipping_info(shipping_info:)
      raise Orders::InvalidOperation unless @state.valid_for_shipping_info_providing?

      apply(Orders::ShippingInfoProvided.new(data: {
        order_id: @order_id,
        receiver_name: shipping_info.name,
        shipping_address: shipping_info.address
      }))
    end

    def provide_contact_info(contact_info:)
      raise Orders::InvalidOperation unless @state.valid_for_contact_info_providing?

      apply(Orders::ContactInfoProvided.new(data: {
        order_id: @order_id,
        contact_phone_number: contact_info.phone_number
      }))
    end

    def submit
      raise Orders::InvalidOperation unless @state.valid_for_submit?
      raise Orders::MissingShippingInfo unless @shipping_info.present?
      raise Orders::ContactInfo unless @contact_info.present?

      apply(OrderSubmitted.new(data: {
        order_id: @order_id
      }))
    end

    def cancel
      raise Orders::InvalidOperation unless @state.valid_for_cancel?

      apply(Orders::OrderCancelled.new(data: {
        order_id: @order_id
      }))
    end

    on Orders::OrderPlaced.new do |_event|
      @state = Orders::OrderState.new(:placed)
    end

    on Orders::ShippingInfoProvided.new do |event|
      @shipping_info = Orders::ShippingInfo.new(
        receiver_name: event.data[:receiver_name], shipping_address: event.data[:shipping_address]
      )
    end

    on Orders::ContactInfoProvided.new do |event|
      @contact_info = Orders::ContactInfo.new(contact_phone_number: event.data[:contact_phone_number])
    end

    on Orders::OrderCancelled.new do |_event|
      @state = Orders::OrderState.new(:cancelled)
    end

    on OrderSubmitted.new do |_event|
      @state = Orders::OrderState.new(:submitted)
    end
  end
end
