require 'spec_helper'

RSpec.describe 'Order commands' do
  it do
    command_bus.call(
      Inventory::RegisterProduct.new(
        product_id: nice_stapler.product_id,
        sku: nice_stapler.sku,
        name: nice_stapler.name
      )
    )

    command_bus.call(
      Inventory::SetProductQuantity.new(
        product_id: nice_stapler.product_id,
        quantity: 20
      )
    )

    command_bus.call(
      Orders::PlaceOrder.new(
        order_id: order.id,
        order_lines: order.lines
      )
    )

    command_bus.call(
      Orders::ProvideShippingInfo.new(
        order_id: order.id,
        receiver_name: shipping_info.receiver_name,
        shipping_address: shipping_info.shipping_address
      )
    )

    command_bus.call(
      Orders::ProvideContactInfo.new(
        order_id: order.id,
        contact_phone_number: contact_phone_number
      )
    )

    command_bus.call(
      Orders::SubmitOrder.new(
        order_id: order.id
      )
    )

    expect(event_store).to have_published(an_event(Fulfillment::OrderAccepted))
    expect(event_store).to have_published(an_event(Inventory::ProductQuantitySet)).exactly(2).times

    expect(Fulfillment::InventoryReadModel.new.product_quantity(nice_stapler.product_id)).to eq(0)
  end

  def command_bus
    Rails.configuration.command_bus
  end

  def event_store
    Rails.configuration.event_store
  end

  def order
    OpenStruct.new(
      id: 'db813466-d829-4c4d-a2f4-4ed372a0e563',
      lines: [
        product_id: nice_stapler.product_id, sku: nice_stapler.sku, quantity: 20, price: 20_00, currency: 'USD'
      ]
    )
  end

  def contact_phone_number
    '321-322-6227'
  end

  def shipping_info
    OpenStruct.new(
      receiver_name: 'Sophia Bartlett',
      shipping_address: '682 Terry Lane Apopka, FL 32703'
    )
  end

  def nice_stapler
    OpenStruct.new(
      product_id: '8277d4c5-37d5-4ef8-bd82-4c476e3070d2',
      sku: 'MT166-0001',
      name: 'Nice stapler'
    )
  end
end
