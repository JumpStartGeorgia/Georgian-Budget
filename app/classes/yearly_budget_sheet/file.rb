class YearlyBudgetSheet::File
  def self.file_paths(folder)
    Dir.glob(Pathname.new(folder).join(self.file_name_glob))
  end

  def self.new_from_file(path)
    new(spreadsheet_path: path)
  end

  def initialize(args = {})
    @spreadsheet_path = args[:spreadsheet_path]
    @excel_data = args[:excel_data]
    @data_rows = args[:data_rows]
    @publish_date = args[:publish_date]
  end

  def save_data
    puts "Saving data in yearly budget sheet: #{spreadsheet_path}"

    I18n.locale = 'ka'

    data_rows.each_with_index do |row_data, index|
      remaining_rows = data_rows.count - index
      if remaining_rows % 100 == 0
        puts "#{remaining_rows} remaining rows to process in #{year} spreadsheet"
      end

      spreadsheet_item = YearlyBudgetSheet::Item.new(header_row_data: row_data)
      next unless spreadsheet_item.has_valid_header_row_data?

      # puts "\nfound header row ##{row_data.r}"
      # puts "code: #{spreadsheet_item.code_number}"
      # puts "name: #{spreadsheet_item.name_ka}"
      # puts "#{year - 2} spent: #{spreadsheet_item.two_years_earlier_spent_amount}"
      # puts "#{year - 1} plan: #{spreadsheet_item.previous_year_plan_amount}"
      # puts "#{year} plan: #{spreadsheet_item.current_year_plan_amount}"

      item_data_compiler = YearlyBudgetSheet::ItemDataCompiler.new(
        spreadsheet_item,
        year: Year.for_date(publish_date)
      )

      BudgetDataSaver.new(item_data_compiler).save_data
    end
  end

  def year
    publish_date.year
  end

  def publish_date
    @publish_date ||= get_publish_date
  end

  attr_reader :spreadsheet_path

  private

  def row_is_item_header?(row_data)
    binding.pry if row_data.r == 4
  end

  def get_publish_date
    match = filename_date_regex.match(spreadsheet_path)
    if match.nil?
      raise "Cannot parse date from spreadsheet filename: #{spreadsheet_path}"
    end

    Date.new(match[1].to_i, 1, 1)
  end

  def filename_date_regex
    /-(\d+)-/
  end

  def data_rows
    @data_rows ||= excel_data[0]
  end

  def excel_data
    @excel_data ||= get_excel_data
  end

  def get_excel_data
    require 'rubyXL'
    RubyXL::Parser.parse(spreadsheet_path)
  end

  def self.file_name_glob
    '**/yearly_spreadsheet*formatted*.xlsx'
  end
end
