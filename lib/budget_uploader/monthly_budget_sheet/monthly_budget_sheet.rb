require_relative 'monthly_budget_sheet_item'
require_relative 'monthly_budget_sheet_row'

class MonthlyBudgetSheet

  def self.file_paths(folder)
    Dir.glob(Pathname.new(folder).join(self.file_name_glob))
  end

  def initialize(spreadsheet_path)
    @spreadsheet_path = spreadsheet_path
  end

  def save_data
    puts "Saving data in monthly budget sheet: #{spreadsheet_path}"

    data = parse
    data_rows = data[0]
    current_item = nil

    data_rows.each_with_index do |row_data, index|
      row = MonthlyBudgetSheetRow.new(row_data)

      next unless row.contains_data?

      if row.is_header?
        # save the previous budget item
        current_item.save unless current_item.nil?

        # create a new budget item
        current_item = MonthlyBudgetSheetItem.new(
          [row],
          start_date
        )
      else
        next unless current_item.present?
        current_item.rows << row
      end
    end
  end

  private

  def start_date
    match = filename_date_regex.match(spreadsheet_path)
    month = match[1].to_i
    year = match[2].to_i

    Date.new(year, month, 1)
  end

  def filename_date_regex
    /ShesBiu.*?(\w+)\.(\w+).xlsx/
  end

  def self.file_name_glob
    '*ShesBiu*.xlsx'
  end

  def parse
    RubyXL::Parser.parse(spreadsheet_path)
  end

  attr_reader :spreadsheet_path
  attr_reader :starting_row
end
