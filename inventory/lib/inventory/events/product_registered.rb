module Inventory
  class ProductRegistered < RailsEventStore::Event
    SCHEMA = {
      product_id: String,
      sku: String,
      name: String,
      quantity: Integer
    }.freeze

    def self.strict(data:)
      ClassyHash.validate(data, SCHEMA)
      new(data: data)
    end
  end
end
