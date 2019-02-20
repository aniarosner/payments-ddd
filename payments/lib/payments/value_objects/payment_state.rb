module Payments
  class PaymentState
    def initialize(state)
      @state = state
    end

    def initialized?
      @state == :initialized
    end

    def assigned_to_order?
      @state == :assigned_to_order
    end

    def charged?
      @state == :charged
    end

    def authorized?
      @state == :authorized
    end

    def captured?
      @state == :captured
    end

    def released?
      @state == :released
    end

    def refunded?
      @state == :refunded
    end

    def failed_charge?
      @state == :failed_charge
    end

    def failed_authorization?
      @state == :failed_authorization
    end

    def failed_capture?
      @state == :failed_capture
    end

    def failed_release?
      @state == :failed_release
    end

    def failed_refund?
      @state == :failed_refund
    end

    def valid_for_assignment?
      initialized?
    end

    def valid_for_charge?
      assigned_to_order? || failed_charge?
    end

    def valid_for_authorization?
      assigned_to_order? || failed_authorization?
    end

    def valid_for_capture?
      authorized? || failed_capture?
    end

    def valid_for_release?
      authorized? || failed_release?
    end

    def valid_for_refund?
      captured? || charged? || failed_refund?
    end
  end
end
