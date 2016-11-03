module MonthlyBudgetSheet
  class Item
    def initialize(rows = {})
      @header_row = rows[:header_row]
      @totals_row = rows[:totals_row]
    end

    attr_accessor :header_row, :totals_row

    def spent_finance_cumulative
      totals_row.spent_finance
    end

    def planned_finance_cumulative
      totals_row.planned_finance
    end

    def name_text
      header_row.name
    end

    def primary_code
      header_row.code
    end
  end
end
