require_relative 'monthly_budget_sheet_item'
require_relative 'monthly_budget_sheet_row'

class MonthlyBudgetSheet

  def self.file_paths(folder)
    Dir.glob(Pathname.new(folder).join(self.file_name_glob))
  end

  def initialize(spreadsheet_path)
    @spreadsheet_path = spreadsheet_path
    @starting_row = 6
  end

  def save_data
    puts "Saving data in monthly budget sheet: #{spreadsheet_path}"

    data = parse
    data_rows = data[0]
    current_item = nil

    data_rows[starting_row..data_rows.count].each_with_index do |row_data, index|
      row = MonthlyBudgetSheetRow.new(row_data)

      # If the row is a header, then save the previous item and replace
      # it with the new item.
      if row.is_header?
        current_item.save unless current_item.nil?
        current_item = MonthlyBudgetSheetItem.new([row])
      else
        current_item.rows << row
      end
    end
  end

  private

  def self.file_name_glob
    '*ShesBiu*.xlsx'
  end

  def parse
    RubyXL::Parser.parse(spreadsheet_path)
  end

  attr_reader :spreadsheet_path
  attr_reader :starting_row
end
