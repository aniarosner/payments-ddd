module Orders
  class OrderState
    def initialize(state)
      @state = state
    end

    def initialized?
      @state == :initialized
    end

    def placed?
      @state == :placed
    end

    def submitted?
      @state == :submitted
    end

    def shipped?
      @state == :shipped
    end

    def cancelled?
      @state == :cancelled
    end

    def valid_for_place?
      initialized?
    end

    def valid_for_shipping_info_providing?
      placed?
    end

    def valid_for_contact_info_providing?
      placed?
    end

    def valid_for_submit?
      placed?
    end

    def valid_for_shipping?
      submitted?
    end

    def valid_for_cancel?
      placed? || submitted?
    end
  end
end
