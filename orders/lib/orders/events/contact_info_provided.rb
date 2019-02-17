module Orders
  class ContactInfoProvided < RailsEventStore::Event
    SCHEMA = {
      order_id: String,
      contact_phone_number: String
    }.freeze

    def self.strict(data:)
      ClassyHash.validate(data, SCHEMA)
      new(data: data)
    end
  end
end
