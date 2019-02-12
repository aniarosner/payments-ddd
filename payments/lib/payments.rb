module Payments
end
require_dependency 'payments/commands/authorize_credit_catd.rb'
require_dependency 'payments/commands/capture_authorization.rb'
require_dependency 'payments/commands/charge_credit_catd.rb'
require_dependency 'payments/commands/refund_payment.rb'
require_dependency 'payments/commands/release_authorization.rb'

require_dependency 'payments/events/capture_failed.rb'
require_dependency 'payments/events/capture_succeded.rb'
require_dependency 'payments/events/payment_failed.rb'
require_dependency 'payments/events/payment_succeded.rb'
require_dependency 'payments/events/refund_failed.rb'
require_dependency 'payments/events/refund_succeded.rb'
require_dependency 'payments/events/release_failed.rb'
require_dependency 'payments/events/release_succeded.rb'
