module Orders
  class OrderPlaced < RailsEventStore::Event
    SCHEMA = {
      order_id: String,
      order_lines: Array
    }.freeze

    def self.strict(data:)
      ClassyHash.validate(data, SCHEMA)
      new(data: data)
    end
  end
end
