module Payments
  class PaymentRefundFailed < RailsEventStore::Event
    SCHEMA = {
      payment_id: String
    }.freeze

    def self.strict(data:)
      ClassyHash.validate(data, SCHEMA)
      new(data: data)
    end
  end
end
