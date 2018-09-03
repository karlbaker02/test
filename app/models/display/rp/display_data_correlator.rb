module Display
  module Rp
    class DisplayDataCorrelator
      Transactions = Struct.new(:name_homepage, :name_only) do
        def any?
          name_homepage.any? || name_only.any?
        end
      end

      def correlate(transactions)
        transaction_list = TransactionList.from(transactions)
        transactions_name_homepage = transaction_list.select_with_homepage.with_display_data.to_a
        transactions_name_only = transaction_list.select_without_homepage.with_display_data.to_a
        Transactions.new(transactions_name_homepage, transactions_name_only)
      end
    end
  end
end
