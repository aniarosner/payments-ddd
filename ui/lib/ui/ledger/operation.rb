module UI
  module Ledger
    class Operation < ActiveRecord::Base
      self.table_name = 'ui_ledger_operations'

      scope :paginate, ->(per_page, offset) { limit(per_page).offset(offset) }

      def amount
        UI::Amount.new(value, currency)
      end

      def amount=(amount)
        self.value    = amount.to_i
        self.currency = amount.currency_symbol
      end
    end
  end
end
