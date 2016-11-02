module MonthlyBudgetSheet
  class DataSaver
    def initialize
    end

    def save_data(args)
      extract_args(args)

      save_spent_finance
      save_planned_finance
    end

    attr_accessor :budget_item,
                  :start_date,
                  :spent_finance_cumulative,
                  :planned_finance_cumulative,
                  :warnings

    private

    def extract_args(args)
      self.budget_item = args[:budget_item]
      self.start_date = args[:start_date]
      self.spent_finance_cumulative = args[:spent_finance_cumulative]
      self.planned_finance_cumulative = args[:planned_finance_cumulative]
      self.warnings = args[:warnings]
    end

    def save_spent_finance
      if spent_finance_amount.present?
        budget_item.add_spent_finance(
          time_period: month,
          amount: spent_finance_amount
        )
      else
        add_warning 'Could not get the spent finance amount'
      end
    end

    def save_planned_finance
      if planned_finance_amount.present?
        budget_item.add_planned_finance(
          time_period: quarter,
          announce_date: start_date,
          amount: planned_finance_amount
        )
      else
        add_warning 'Could not get the planned finance amount'
      end
    end

    # The amounts recorded in the spreadsheets are cumulative within the year.
    # For example, the spent finance recorded for March is the total
    # spending of January, February and March, and the planned finance
    # recorded for Quarter 2 is the total planned amount for the first
    # two quarters.

    # We don't want to save the cumulative amount, so these methods
    # get the non-cumulative amounts.
    def spent_finance_amount
      return nil unless spent_finance_cumulative.present?

      previously_spent = budget_item.spent_finances.year_cumulative_up_to(start_date)
      spent_finance_cumulative - previously_spent
    end

    def planned_finance_amount
      return nil unless planned_finance_cumulative.present?

      previously_spent = budget_item.planned_finances.year_cumulative_up_to(start_date)
      planned_finance_cumulative - previously_spent
    end

    def month
      Month.for_date(start_date)
    end

    def quarter
      Quarter.for_date(start_date)
    end

    def add_warning(msg)
      warnings << msg
    end
  end
end
