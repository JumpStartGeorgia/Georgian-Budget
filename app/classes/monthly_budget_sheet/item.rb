module MonthlyBudgetSheet
  class Item
    def initialize(rows, args)
      @rows = rows
      @start_date = args[:start_date]
      @item_saver = ItemSaver.new(warnings: args[:warnings])
    end

    def save
      item_saver.save_data_from_monthly_sheet_item(self)

      self.budget_item_object = item_saver.budget_item
    end

    attr_reader :item_saver

    attr_accessor :rows,
                  :start_date,
                  :budget_item_object

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

    def header_row
      rows.find(&:is_header?)
    end

    def totals_row
      rows.find(&:is_totals_row?)
    end
  end
end
