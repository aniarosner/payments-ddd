module Fulfillment
end

require_dependency 'fulfillment/commands/accept_order.rb'
require_dependency 'fulfillment/commands/reject_order.rb'

require_dependency 'fulfillment/events/order_accepted.rb'
require_dependency 'fulfillment/events/order_rejected.rb'

require_dependency 'fulfillment/value_objects/order_state.rb'

require_dependency 'fulfillment/order_command_handler.rb'
require_dependency 'fulfillment/order.rb'