module Orders
  class OrderState
    def initialize(state)
      @state = state
    end

    def initialized?
      state == :initialized
    end

    def valid_for_place?
      state.initialized?
    end
  end
end
