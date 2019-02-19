require 'spec_helper'

RSpec.describe 'Maintaining inventory' do
  let(:command_bus) { Rails.configuration.command_bus }

  it do
    command_bus.call(
      Inventory::RegisterProduct.new(
        product_id: nice_stapler_product.product_id,
        sku: nice_stapler_product.sku,
        name: nice_stapler_product.name
      )
    )

    expect(Fulfillment::InventoryReadModel.new.all.count).to eq(1)
    expect(Fulfillment::InventoryReadModel.new.all.first.product_id).to eq(nice_stapler_product.product_id)
    expect(Fulfillment::InventoryReadModel.new.all.first.sku).to eq(nice_stapler_product.sku)
    expect(Fulfillment::InventoryReadModel.new.all.first.name).to eq(nice_stapler_product.name)
    expect(Fulfillment::InventoryReadModel.new.product_quantity(nice_stapler_product.product_id)).to eq(0)

    command_bus.call(
      Inventory::SetProductQuantity.new(
        product_id: nice_stapler_product.product_id,
        quantity: 10
      )
    )

    expect(Fulfillment::InventoryReadModel.new.product_quantity(nice_stapler_product.product_id)).to eq(10)

    command_bus.call(
      Inventory::IncreaseProductQuantity.new(
        product_id: nice_stapler_product.product_id,
        quantity: 1
      )
    )

    expect(Fulfillment::InventoryReadModel.new.product_quantity(nice_stapler_product.product_id)).to eq(11)

    command_bus.call(
      Inventory::DecreaseProductQuantity.new(
        product_id: nice_stapler_product.product_id,
        quantity: 1
      )
    )

    expect(Fulfillment::InventoryReadModel.new.product_quantity(nice_stapler_product.product_id)).to eq(10)
  end

  def nice_stapler_product
    OpenStruct.new(
      product_id: '8277d4c5-37d5-4ef8-bd82-4c476e3070d2',
      sku: 'MT166-0001',
      name: 'Nice stapler'
    )
  end
end
