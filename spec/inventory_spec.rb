require 'spec_helper'

RSpec.describe 'Maintaining inventory' do
  let(:command_bus) { Rails.configuration.command_bus }

  it 'registers product' do
    command_bus.call(
      Inventory::RegisterProduct.new(
        product_id: nice_stapler_product.product_id,
        sku: nice_stapler_product.sku,
        name: nice_stapler_product.name
      )
    )

    expect(Fulfillment::InventoryReadModel.new.all.count).to eq(1)
    expect(Fulfillment::InventoryReadModel.new.first.product_id).to eq(nice_stapler_product.product_id)
    expect(Fulfillment::InventoryReadModel.new.first.sku).to eq(nice_stapler_product.sku)
    expect(Fulfillment::InventoryReadModel.new.first.name).to eq(nice_stapler_product.name)
    expect(Fulfillment::InventoryReadModel.new.first.quantity).to eq(0)
  end

  def nice_stapler_product
    {
      product_id: '8277d4c5-37d5-4ef8-bd82-4c476e3070d2',
      sku: 'MT166-0001',
      name: 'Nice stapler'
    }
  end
end
