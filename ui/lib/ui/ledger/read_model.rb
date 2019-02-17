module UI
  module Ledger
    class ReadModel
      def paginate(per_page, offset)
        per_page(per_page)
        offset(offset)
      end

      def all
        UI::Ledger::Operation.all.paginate(@per_page, @offset)
      end

      private

      def per_page(per_page)
        @per_page = per_page
        self
      end

      def offset(offset)
        @offset = offset
        self
      end
    end
  end
end
