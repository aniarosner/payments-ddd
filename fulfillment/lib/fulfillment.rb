module Fulfillment
end

require_dependency 'fulfillment/commands/accept_order.rb'
require_dependency 'fulfillment/commands/reject_order.rb'

require_dependency 'fulfillment/domain_services/check_product_availability.rb'

require_dependency 'fulfillment/events/order_accepted.rb'
require_dependency 'fulfillment/events/order_rejected.rb'

require_dependency 'fulfillment/listeners/on_order_submitted.rb'

require_dependency 'fulfillment/read_models/inventory/on_product_quantity_set.rb'
require_dependency 'fulfillment/read_models/inventory/on_product_registered.rb'
require_dependency 'fulfillment/read_models/inventory/product.rb'
require_dependency 'fulfillment/read_models/inventory/read_model.rb'

require_dependency 'fulfillment/value_objects/order_line.rb'
require_dependency 'fulfillment/value_objects/order_state.rb'

require_dependency 'fulfillment/order_command_handler.rb'
require_dependency 'fulfillment/order.rb'
