module Inventory
  class ProductQuantitySet < RailsEventStore::Event
    SCHEMA = {
      product_id: String,
      quantity: Integer
    }.freeze

    def self.strict(data:)
      ClassyHash.validate(data, SCHEMA)
      new(data: data)
    end
  end
end
