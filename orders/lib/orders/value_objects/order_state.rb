module Orders
  class OrderState
    def initialize(state)
      @state = state
    end

    def initialized?
      state == :initialized
    end

    def placed?
      state == :placed
    end

    def cancelled?
      state == :cancelled
    end

    def valid_for_place?
      state.initialized?
    end

    def valid_for_shipping_info_providing?
      state.placed?
    end

    def valid_for_contact_info_providing?
      state.placed?
    end

    def valid_for_submit?
      state.placed?
    end

    def valid_for_cancel?
      state.placed? || state.submitted?
    end
  end
end
