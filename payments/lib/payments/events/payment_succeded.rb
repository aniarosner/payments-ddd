module Payments
  class PaymentSucceded < RailsEventStore::Event
    SCHEMA = {
      payment_id: String,
      credit_card: String,
      amount: Integer,
      currency: String,
      transaction_identifier: String
    }.freeze

    def self.strict(data:)
      ClassyHash.validate(data, SCHEMA)
      new(data: data)
    end
  end
end
