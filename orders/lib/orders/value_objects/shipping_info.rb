module Orders
  class ShippingInfo
    include Comparable
    InvalidFormat = Class.new(StandardError)

    def initialize(receiver_name:, shipping_address:)
      raise InvalidFormat unless receiver_name.class == String && shipping_address.class == String

      @receiver_name    = receiver_name
      @shipping_address = shipping_address
    end

    def <=>(other)
      self.class == other.class && receiver_name == other.receiver_name && shipping_address == other.shipping_address ? 0 : -1
    end

    alias eql? ==

    def name
      receiver_name
    end

    def address
      shipping_address
    end

    protected

    attr_reader :receiver_name, :shipping_address
  end
end
