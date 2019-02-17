module Orders
  class ContactInfo
    include Comparable
    InvalidFormat = Class.new(StandardError)

    def initialize(contact_phone_number:)
      raise InvalidFormat unless contact_phone_number.class == String

      @contact_phone_number = contact_phone_number
    end

    def <=>(other)
      self.class == other.class && contact_phone_number == other.contact_phone_number ? 0 : -1
    end

    alias eql? ==

    def phone_number
      contact_phone_number
    end

    protected

    attr_reader :contact_phone_number
  end
end
