module Payments
  class Amount
    include Comparable

    def initialize(value, currency)
      @value = value
      @currency = currency
    end

    def <=>(other)
      self.class == other.class && value == other.value && currency == other.currency ? 0 : -1
    end

    def to_f
      value
    end

    def to_s
      "#{format('%.2f', value)} #{currency}"
    end

    def +(other)
      raise ArgumentError if currency != other.currency

      self.class.new(value + other.value, currency)
    end

    def -(other)
      raise ArgumentError if currency != other.currency

      self.class.new(value - other.value, currency)
    end

    protected

    attr_reader :value, :currency
  end
end
