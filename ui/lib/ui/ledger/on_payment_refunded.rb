module UI
  module Ledger
    class OnPaymentSucceded
      def call(event)
        UI::Ledger::Operation.create!(
          payment_id: event.data[:payment_id],
          amount: -event.data[:amount],
          currency: event.data[:currency],
          transaction_identifier: event.data[:transaction_identifier],
          timestamp: event.metadata[:time]
        )
      end
    end
  end
end
