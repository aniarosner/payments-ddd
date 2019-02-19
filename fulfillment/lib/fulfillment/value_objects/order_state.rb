module Fulfillment
  class OrderState
    def initialize(state)
      @state = state
    end

    def initialized?
      state == :initialized
    end

    def accepted?
      state == :accepted
    end

    def rejeceted?
      state == :rejeceted
    end
  end
end
