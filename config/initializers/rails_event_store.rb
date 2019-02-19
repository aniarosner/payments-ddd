require 'rails_event_store'
require 'aggregate_root'
require 'arkency/command_bus'

Rails.configuration.to_prepare do
  Rails.configuration.event_store = RailsEventStore::Client.new
  Rails.configuration.command_bus = Arkency::CommandBus.new

  AggregateRoot.configure do |config|
    config.default_event_store = Rails.configuration.event_store
  end

  Rails.configuration.event_store.tap do |store|
    store.subscribe(Fulfillment::OnOrderSubmitted, to: [Orders::OrderSubmitted])
    store.subscribe(Fulfillment::Inventory::OnProductQuantitySet, to: [Inventory::ProductQuantitySet])
    store.subscribe(Fulfillment::Inventory::OnProductRegistered, to: [Inventory::ProductRegistered])

    store.subscribe(Inventory::OnOrderAccepted, to: [Fulfillment::OrderAccepted])

    store.subscribe(
      Orders::OrderShippingProcess.new(event_store: store, command_bus: Rails.configuration.command_bus), to:
      [Orders::OrderSubmitted, Orders::OrderShipped, Payments::PaymentAssignedToOrder, Payments::CreditCardAuthorized,
       Fulfillment::OrderAccepted, Fulfillment::OrderRejected, Orders::OrderCancelled]
    )

    store.subscribe(
      Payments::CreditCardAuthorizationProcess.new(event_store: store, command_bus: Rails.configuration.command_bus), to:
      [Orders::OrderSubmitted, Payments::PaymentAssignedToOrder, Payments::CreditCardAuthorized,
       Payments::AuthorizationCaptured, Payments::AuthorizationReleased, Orders::OrderShipped, Orders::OrderCancelled]
    )

    store.subscribe(UI::Ledger::OnAuthorizationCaptured, to: [Payments::AuthorizationCaptured])
    store.subscribe(UI::Ledger::OnPaymentRefunded, to: [Payments::PaymentRefunded])
    store.subscribe(UI::Ledger::OnPaymentSucceded, to: [Payments::PaymentSucceded])
  end

  Rails.configuration.command_bus.tap do |bus|
    bus.register(Fulfillment::AcceptOrder, ->(cmd) { Fulfillment::OrderCommandHandler.new.accept_order(cmd) })
    bus.register(Fulfillment::RejectOrder, ->(cmd) { Fulfillment::OrderCommandHandler.new.reject_order(cmd) })

    bus.register(Inventory::DecreaseProductQuantity, ->(cmd) { Inventory::ProductCommandHandler.new.decrease_product_quantity(cmd) })
    bus.register(Inventory::IncreaseProductQuantity, ->(cmd) { Inventory::ProductCommandHandler.new.increase_product_quantity(cmd) })
    bus.register(Inventory::RegisterProduct, ->(cmd) { Inventory::ProductCommandHandler.new.register_product(cmd) })
    bus.register(Inventory::SetProductQuantity, ->(cmd) { Inventory::ProductCommandHandler.new.set_product_quantity(cmd) })

    bus.register(Orders::CancelOrder, ->(cmd) { Orders::OrderCommandHandler.new.cancel_order(cmd) })
    bus.register(Orders::PlaceOrder, ->(cmd) { Orders::OrderCommandHandler.new.place_order(cmd) })
    bus.register(Orders::ProvideContactInfo, ->(cmd) { Orders::OrderCommandHandler.new.provide_contact_info(cmd) })
    bus.register(Orders::ProvideShippingInfo, ->(cmd) { Orders::OrderCommandHandler.new.provide_shipping_info(cmd) })
    bus.register(Orders::ShipOrder, ->(cmd) { Orders::OrderCommandHandler.new.ship_order(cmd) })
    bus.register(Orders::SubmitOrder, ->(cmd) { Orders::OrderCommandHandler.new.submit_order(cmd) })

    bus.register(Payments::AssignPaymentToOrder, ->(cmd) { Payments::CreditCardPaymentCommandHandler.new.assign_payment_to_order(cmd) })
    bus.register(Payments::AuthorizeCreditCard, ->(cmd) { Payments::CreditCardPaymentCommandHandler.new.authorize_credit_card(cmd) })
    bus.register(Payments::CaptureAuthorization, ->(cmd) { Payments::CreditCardPaymentCommandHandler.new.capture_authorization(cmd) })
    bus.register(Payments::ChargeCreditCard, ->(cmd) { Payments::CreditCardPaymentCommandHandler.new.charge_credit_card(cmd) })
    bus.register(Payments::RefundPayment, ->(cmd) { Payments::CreditCardPaymentCommandHandler.new.refund_payment(cmd) })
    bus.register(Payments::ReleaseAuthorization, ->(cmd) { Payments::CreditCardPaymentCommandHandler.new.release_authorization(cmd) })
  end
end
