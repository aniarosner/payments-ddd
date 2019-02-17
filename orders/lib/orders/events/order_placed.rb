module Orders
  class OrderPlaced < RailsEventStore::Event
    SCHEMA = {
      order_id: String,
    }.freeze

    def self.strict(data:)
      ClassyHash.validate(data, SCHEMA)
      new(data: data)
    end
  end
end
