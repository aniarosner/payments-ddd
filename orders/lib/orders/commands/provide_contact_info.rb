module Orders
  class ProvideContactInfo
    include Command
    attr_accessor :order_id,
                  :contact_phone_number

    def initialize(order_id:, contact_phone_number:)
      @order_id             = order_id
      @contact_phone_number = contact_phone_number
    end
  end
end
