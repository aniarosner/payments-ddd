module Orders
  class ShippingInfoProvided < RailsEventStore::Event
    SCHEMA = {
      order_id: String,
      receiver_name: String,
      shipping_address: String
    }.freeze

    def self.strict(data:)
      ClassyHash.validate(data, SCHEMA)
      new(data: data)
    end
  end
end
