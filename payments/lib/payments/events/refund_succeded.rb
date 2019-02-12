module Payments
  class RefundSucceded < RailsEventStore::Event
    SCHEMA = {
    }.freeze

    def self.strict(data:)
      ClassyHash.validate(data, SCHEMA)
      new(data: data)
    end
  end
end
