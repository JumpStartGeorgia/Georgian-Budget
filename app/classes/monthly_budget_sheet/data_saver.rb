module MonthlyBudgetSheet
  class DataSaver
    def initialize
    end

    def save_data(args)
      extract_args(args)

      save_planned_finance
    end

    attr_accessor :budget_item,
                  :start_date,
                  :planned_finance_cumulative,
                  :warnings

    private

    def extract_args(args)
      self.budget_item = args[:budget_item]
      self.start_date = args[:start_date]
      self.planned_finance_cumulative = args[:planned_finance_cumulative]
      self.warnings = args[:warnings]
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

    def planned_finance_amount
      previously_spent = budget_item.planned_finances.year_cumulative_up_to(start_date)
      return nil unless planned_finance_cumulative.present?

      planned_finance_cumulative - previously_spent
    end

    def quarter
      Quarter.for_date(start_date)
    end

    def add_warning(msg)
      warnings << msg
    end
  end
end
