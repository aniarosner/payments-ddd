module Payments
  class PayPalAdapter
    def charge(credit_card:, amount:); end

    def authorize(credit_card:, amount:)
      Payments::Transaction.new('transaction')
    end

    def capture(transaction:, amount:); end

    def release(transaction:); end

    def refund(transaction:, amount:); end
  end
end
