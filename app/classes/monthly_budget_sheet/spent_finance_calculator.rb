module MonthlyBudgetSheet
  class SpentFinanceCalculator
    def initialize(args)
      @budget_item = args[:budget_item]
      @spent_finance_cumulative = args[:spent_finance_cumulative]
      @start_date = args[:start_date]
    end

    def get_data
      return nil unless spent_finance_amount.present?

      {
        time_period: month,
        amount: spent_finance_amount
      }
    end

    attr_reader :spent_finance_cumulative,
                :start_date,
                :budget_item

    private

    def spent_finance_amount
      return nil unless spent_finance_cumulative.present?

      previously_spent = budget_item.spent_finances.year_cumulative_up_to(start_date)
      spent_finance_cumulative - previously_spent
    end

    def month
      Month.for_date(start_date)
    end
  end
end
