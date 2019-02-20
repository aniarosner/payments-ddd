module UI
  module Ledger
    class OnAuthorizationCaptured
      def call(event)
        UI::Ledger::Operation.create!(
          payment_id: event.data[:payment_id],
          amount: UI::Amount.new(event.data[:amount], event.data[:currency]),
          transaction_identifier: event.data[:transaction_identifier],
          timestamp: event.metadata[:timestamp]
        )
      end
    end
  end
end
