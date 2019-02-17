module UI
  module Ledger
    class Operation < ActiveRecord::Base
      self.table_name = 'ui_ledger_operations'

      scope :paginate, ->(per_page, offset) { limit(per_page).offset(offset) }
    end
  end
end
