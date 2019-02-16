module Payments
  class OrderReference
    include Comparable

    def initialize(transaction_id)
      @transaction_id = transaction_id
    end

    def <=>(other)
      self.class == other.class && transaction_id == other.transaction_id ? 0 : -1
    end

    def identifier
      transaction_id
    end

    protected

    attr_reader :transaction_id
  end
end
