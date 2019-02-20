module Orders
  class OnOrderRejected
    def initialize(command_bus: Rails.configuration.command_bus)
      @command_bus = command_bus
    end

    def call(event)
      @command_bus.call(Orders::CancelOrder.new(order_id: event.data[:order_id]))
    end
  end
end
