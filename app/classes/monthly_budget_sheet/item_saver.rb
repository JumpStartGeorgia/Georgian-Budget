module MonthlyBudgetSheet
  class ItemSaver
    def initialize(monthly_sheet_item, args = {})
      @monthly_sheet_item = monthly_sheet_item
      @warnings = args[:warnings]
      @start_date = args[:start_date]
      @budget_item_fetcher = BudgetItemFetcher.new
    end

    def save_data_from_monthly_sheet_item
      return unless budget_item.present?

      save_code
      save_name
      save_spent_finance
      save_planned_finance

      if budget_item_fetcher.created_new_item && budget_item.respond_to?(:save_possible_duplicates)
        budget_item.save_possible_duplicates
      end
    end

    def budget_item
      @budget_item ||= budget_item_fetcher.fetch(
        create_if_nil: true,
        code_number: code_number,
        name_text: name_text
      )
    end

    attr_reader :budget_item_fetcher,
                :monthly_sheet_item,
                :start_date,
                :warnings

    private

    def save_code
      return unless budget_item.respond_to?(:add_code)
      budget_item.add_code(code_data)
    end

    def code_data
      {
        start_date: start_date,
        number: code_number
      }
    end

    def code_number
      monthly_sheet_item.primary_code
    end

    def save_name
      return unless budget_item.respond_to?(:add_name)
      budget_item.add_name(name_data)
    end

    def name_data
      {
        text_ka: name_text_ka,
        text_en: name_text_en,
        start_date: start_date
      }
    end

    def name_text_ka
      name_text
    end

    def name_text
      Name.clean_text(monthly_sheet_item.name_text)
    end

    def name_text_en
      nil
    end

    def save_spent_finance
      budget_item.add_spent_finance(spent_finance_data)

      unless spent_finance_data[:amount].present?
        add_warning 'Could not get the spent finance amount'
      end
    end

    def spent_finance_data
      {
        time_period: month,
        amount: NonCumulativeFinanceCalculator.calculate(
          finances: budget_item.spent_finances,
          cumulative_amount: spent_finance_cumulative,
          start_date: start_date
        )
      }
    end

    def spent_finance_cumulative
      monthly_sheet_item.spent_finance_cumulative
    end

    def month
      Month.for_date(start_date)
    end

    def save_planned_finance
      budget_item.add_planned_finance(planned_finance_data)

      unless planned_finance_data[:amount].present?
        add_warning 'Could not get the planned finance amount'
      end
    end

    def planned_finance_data
      {
        time_period: quarter,
        announce_date: start_date,
        amount: NonCumulativeFinanceCalculator.calculate(
          finances: budget_item.planned_finances,
          start_date: start_date,
          cumulative_amount: planned_finance_cumulative
        )
      }
    end

    def planned_finance_cumulative
      monthly_sheet_item.planned_finance_cumulative
    end

    def quarter
      Quarter.for_date(start_date)
    end

    def add_warning(msg)
      warnings << "Budget Item #{code_number} #{name_text}: #{msg}"
    end
  end
end
