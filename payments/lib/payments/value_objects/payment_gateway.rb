module Payments
  class PaymentGateway
    include Comparable
    InvalidFormat = Class.new(StandardError)

    def initialize(name)
      raise InvalidFormat unless name.class.in?([String, Symbol])

      @name = name.to_sym
    end

    def <=>(other)
      self.class == other.class && name == other.name ? 0 : -1
    end

    def to_s
      name.to_s
    end

    def to_sym
      name
    end

    protected

    attr_reader :name
  end
end
