module Orders
  class Order
    include AggregateRoot

    InvalidOperation = Class.new(StandardError)

    def initialize(order_id)
      @order_id       = order_id
      @order_state    = Orders::OrderState.new(:initialized)
      @order_lines    = []
      @shipping_info  = nil
      @contact_info   = nil
    end

    def place(order_lines)
      raise Orders::InvalidOperation unless @state.valid_for_place?

      apply(Orders::OrderPlaced.new(data: {
        order_id: @order_id,
        order_lines: order_lines.map { |order_line| order_line.to_hash }
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

      apply(Orders::OrderSubmitted.new(data: {
        order_id: @order_id,
        order_lines: @order_lines.map { |order_line| order_line.to_hash }
      }))
    end

    def ship
      raise Orders::InvalidOperation unless @state.valid_for_shipping?

      apply(Orders::OrderShipped.new(data: {
        order_id: @order_id
      }))
    end

    def cancel
      raise Orders::InvalidOperation unless @state.valid_for_cancel?

      apply(Orders::OrderCancelled.new(data: {
        order_id: @order_id
      }))
    end

    on Orders::OrderPlaced do |_event|
      @state = Orders::OrderState.new(:placed)
      @order_lines = event.data[:order_lines].map do |order_line|
        Orders::OrderLine.new(
          product_id: order_line[:product_id], sku: order_line[:sku], quantity: order_line[:quantity],
          price: order_line[:price]
        )
      end
    end

    on Orders::ShippingInfoProvided do |event|
      @shipping_info = Orders::ShippingInfo.new(
        receiver_name: event.data[:receiver_name], shipping_address: event.data[:shipping_address]
      )
    end

    on Orders::ContactInfoProvided do |event|
      @contact_info = Orders::ContactInfo.new(contact_phone_number: event.data[:contact_phone_number])
    end

    on Orders::OrderCancelled do |_event|
      @state = Orders::OrderState.new(:cancelled)
    end

    on Orders::OrderShipped do |_event|
      @state = Orders::OrderState.new(:shipped)
    end

    on OrderSubmitted do |_event|
      @state = Orders::OrderState.new(:submitted)
    end
  end
end
