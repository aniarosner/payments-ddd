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

    def valid_for_assignment?
      state.initialized?
    end

    def valid_for_charge?
      state.assigned_to_order? || state.failed_charge?
    end

    def valid_for_authorization?
      state.assigned_to_order? || state.failed_authorization?
    end

    def valid_for_capture?
      state.authorized? || state.failed_capture?
    end

    def valid_for_release?
      state.authorized? || state.failed_release?
    end

    def valid_for_refund?
      state.captured? || state.charged? || state.failed_refund?
    end
  end
end
