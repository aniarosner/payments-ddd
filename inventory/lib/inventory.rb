module Inventory
  InvalidQuantityFormat = Class.new(StandardError)
end

require_dependency 'inventory/commands/decrease_quantity.rb'
require_dependency 'inventory/commands/increase_product_quantity.rb'
require_dependency 'inventory/commands/register_product.rb'
require_dependency 'inventory/commands/set_product_quantity.rb'

require_dependency 'inventory/listeners/on_order_accepted.rb'

require_dependency 'inventory/events/product_quantity_set.rb'
require_dependency 'inventory/events/product_registered.rb'

require_dependency 'product_command_handler.rb'
require_dependency 'product.rb'
