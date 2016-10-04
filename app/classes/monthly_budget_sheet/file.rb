module MonthlyBudgetSheet
  class File
    def self.file_paths(folder)
      Dir.glob(Pathname.new(folder).join(self.file_name_glob))
    end

    def initialize(spreadsheet_path)
      @spreadsheet_path = spreadsheet_path
      @start_date = Date.new(year, month).beginning_of_month
      @end_date = Date.new(year, month).end_of_month
    end

    def save_data
      puts "Saving data in monthly budget sheet: #{spreadsheet_path}"

      data = parse
      data_rows = data[0]
      current_item = nil

      data_rows.each_with_index do |row_data, index|
        row = Row.new(row_data)

        next unless row.contains_data?

        if row.is_header?
          # save the previous budget item

          current_item.save(start_date, end_date) unless current_item.nil?

          # create a new budget item
          current_item = Item.new([row])
        else
          next unless current_item.present?
          current_item.rows << row
        end
      end
    end

    attr_reader :spreadsheet_path,
                :starting_row,
                :start_date,
                :end_date

    private

    def month
      date_regex_match[1].to_i
    end

    def year
      date_regex_match[2].to_i
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

    def parse
      require 'rubyXL'
      RubyXL::Parser.parse(spreadsheet_path)
    end
  end
end
