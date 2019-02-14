module Payments
  class ReleaseAuthorization
    include Command
    attr_accessor :payment_id

    def initialize(payment_id:)
      @payment_id = payment_id
    end
  end
end
