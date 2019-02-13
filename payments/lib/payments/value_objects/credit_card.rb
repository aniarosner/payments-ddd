module Payments
  class CreditCard
    include Comparable
    InvalidFormat = Class.new(StandardError)

    def initialize(token)
      raise InvalidFormat unless token.class

      @token = token
    end

    alias eql? ==
    attr_reader :token

    def <=>(other)
      self.class == other.class && token == other.token ? 0 : -1
    end
  end
end
