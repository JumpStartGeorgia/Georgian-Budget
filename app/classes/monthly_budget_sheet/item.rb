module MonthlyBudgetSheet
  class Item
    def initialize(rows, args)
      @rows = rows
      @start_date = args[:start_date]
      @warnings = []
      @data_saver = BudgetDataSaver.new
    end

    def save
      data_saver.save_data(DataExtractor.new.extract_from_item(self))

      self.budget_item_object = data_saver.budget_item

      output_warnings
    end

    attr_reader :data_saver

    attr_accessor :rows,
                  :start_date,
                  :warnings,
                  :budget_item_object

    def cumulative_spent_finance_amount
      totals_row.spent_finance
    end

    def cumulative_planned_finance_amount
      totals_row.planned_finance
    end

    def name
      Name.clean_text(header_row.name)
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

    private

    def output_warnings
      return if warnings.empty?

      puts "\nWarnings for budget item between rows #{starting_row_num} and #{last_row_num}"
      warnings.each { |warning| puts "WARNING: #{warning}" }
    end

    def starting_row_num
      header_row.data.r
    end

    def last_row_num
      rows.last.data.r
    end
  end
end
