module MonthlyBudgetSheet
  class File
    def self.file_paths(folder)
      Dir.glob(Pathname.new(folder).join(self.file_name_glob))
    end

    def initialize(spreadsheet_path)
      @spreadsheet_path = spreadsheet_path
      @excel_data = nil
      @start_date = Date.new(year, month).beginning_of_month
      @end_date = Date.new(year, month).end_of_month
      @code_column = nil
      @locale = 'ka'
    end

    def save_data
      puts "Saving data in monthly budget sheet: #{spreadsheet_path}"

      current_item = nil

      I18n.locale = locale

      data_rows.each_with_index do |row_data, index|
        row = create_row(row_data)

        set_columns(row) if row.contains_column_names?

        next unless row.contains_data?

        if row.is_header?
          # save the previous budget item
          current_item.save unless current_item.nil?

          # create a new budget item
          current_item = Item.new([row], start_date, end_date)
        else
          next unless current_item.present?
          current_item.rows << row
        end
      end
    end

    def data_rows
      get_excel_data unless excel_data.present?
      excel_data[0]
    end

    attr_reader :spreadsheet_path,
                :starting_row,
                :start_date,
                :end_date,
                :locale

    attr_accessor :excel_data,
                  :code_column


    def month
      date_regex_match[1].to_i
    end

    def year
      date_regex_match[2].to_i
    end

    def get_excel_data
      require 'rubyXL'
      self.excel_data = RubyXL::Parser.parse(spreadsheet_path)
    end

    private

    def set_columns(row)
      @code_column = row.column_number_for_value('ორგანიზაც. კოდი')
    end

    def create_row(row_data)
      args = {
        code_column: code_column
      }

      if (year == 2012) && ([1, 2].include? month)
        args[:name_column] = 3
        args[:spent_finance_column] = 13
        args[:planned_finance_column] = 5
      end

      Row.new(row_data, args)
    end

    def date_regex_match
      match = filename_date_regex.match(spreadsheet_path)
      raise 'Cannot parse date from filename. Format of file should be monthly_spreadsheet.mm.yyyy' if match.nil?

      match
    end

    def filename_date_regex
      /monthly_spreadsheet.*?(\w+)\.(\w+).xlsx/
    end

    def self.file_name_glob
      '**/monthly_spreadsheet*.xlsx'
    end
  end
end
