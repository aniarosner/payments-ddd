require 'spec_helper'

RSpec.describe 'Release credit card authorization' do
  it do
    # prepare inventory
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
        quantity: nice_stapler.quantity
      )
    )

    # prepare order
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

    # test payments
    command_bus.call(
      Payments::AssignPaymentToOrder.new(
        order_id: order.id,
        payment_id: payment.id
      )
    )

    command_bus.call(
      Payments::AuthorizeCreditCard.new(
        payment_id: payment.id,
        credit_card_token: credit_card_token,
        amount: order_cost.amount,
        currency: order_cost.currency
      )
    )

    expect(event_store).to have_published(an_event(Payments::AuthorizationReleased))
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

  def order_cost
    OpenStruct.new(
      amount: 20_00,
      currency: 'USD'
    )
  end

  def credit_card_token
    '82f3c124-b6a5-4256-8713-3dd8378c333f'
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
      name: 'Nice stapler',
      quantity: 10
    )
  end

  def payment
    OpenStruct.new(
      id: '72ccaa10-2bed-4616-ab1e-cd75aed6cc72'
    )
  end
end
