module Payments
  class PaymentState
    def initialize(state)
      @state = state
    end

    def initialized?
      state == :initialized
    end

    def assigned_to_order?
      state == :assigned_to_order
    end

    def charged?
      state == :charged
    end

    def authorized?
      state == :authorized
    end

    def captured?
      state == :captured
    end

    def released?
      state == :released
    end

    def refunded?
      state == :refunded
    end

    def failed_charge?
      state == :failed_charge
    end

    def failed_authorization?
      state == :failed_authorization
    end

    def failed_capture?
      state == :failed_capture
    end

    def failed_release?
      state == :failed_release
    end

    def failed_refund?
      state == :failed_refund
    end

    def can_assign?
      state.initialized?
    end

    def can_select_payment_gateway?
      state.initialized? || state.assigned_to_order? || state.failed_charge? || state.failed_authorization
    end

    def can_charge?
      state.assigned_to_order? || state.failed_charge?
    end

    def can_authorize?
      state.assigned_to_order? || state.failed_authorization?
    end

    def can_capture?
      state.authorized? || state.failed_capture?
    end

    def can_release?
      state.authorized? || state.failed_release?
    end

    def can_refund?
      state.captured? || state.charged? || state.failed_refund?
    end
  end
end
