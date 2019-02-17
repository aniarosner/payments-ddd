module Orders
end

require_dependency 'orders/commands/cancel_order.rb'
require_dependency 'orders/commands/place_order.rb'
require_dependency 'orders/commands/provide_contact_info.rb'
require_dependency 'orders/commands/provide_shipping_info.rb'
require_dependency 'orders/commands/submit_order.rb'

require_dependency 'orders/events/contanct_info_provided.rb'
require_dependency 'orders/events/order_cancelled.rb'
require_dependency 'orders/events/order_placed.rb'
require_dependency 'orders/events/order_submitted.rb'
require_dependency 'orders/events/shipping_info_provided.rb'

require_dependency 'orders/value_objects/contact_info.rb'
require_dependency 'orders/value_objects/order_state.rb'
require_dependency 'orders/value_objects/shipping_info.rb'

require_dependency 'orders/order_command_handler.rb'
require_dependency 'orders/order.rb'
