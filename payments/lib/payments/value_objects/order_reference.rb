module Payments
  class OrderReference
    include Comparable

    def initialize(value)
      @value = value
    end

    def <=>(other)
      self.class == other.class && value == other.value ? 0 : -1
    end

    def to_s
      value
    end

    protected

    attr_reader :value
  end
end
