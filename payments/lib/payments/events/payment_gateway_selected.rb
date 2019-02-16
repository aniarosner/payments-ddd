module Payments
  class PaymentGatewaySelected < RailsEventStore::Event
    SCHEMA = {
      payment_id: String,
      payment_gateway: Symbol
    }.freeze

    def self.strict(data:)
      ClassyHash.validate(data, SCHEMA)
      new(data: data)
    end
  end
end
