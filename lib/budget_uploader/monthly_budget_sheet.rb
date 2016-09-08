require_relative 'monthly_budget_sheet_item'
require_relative 'monthly_budget_sheet_row'

class MonthlyBudgetSheet
  def initialize(spreadsheet_path)
    @spreadsheet_path = spreadsheet_path
  end

  def save_data
    data = parse
    data_rows = data[0]
    starting_row = 6

    data_rows[starting_row..data_rows.count].each_with_index do |row_data, index|
      row = MonthlyBudgetSheetRow.new(row_data)

      next unless row.is_item?

      budget_item = MonthlyBudgetSheetItem.new([row])
      budget_item.save_data
    end
  end

  private

  def parse
    RubyXL::Parser.parse(spreadsheet_path)
  end

  attr_reader :spreadsheet_path
end
