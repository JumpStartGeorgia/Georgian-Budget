require_relative 'row'

module PriorityAssociations
  class List
    def self.new_from_file(file_path, args)
      require 'csv'
      self.new(CSV.read(file_path), args)
    end

    def initialize(rows, args)
      @rows = rows
      @priorities_list = args[:priorities_list]
    end

    def save
      I18n.with_locale('ka') do
        rows.each_with_index do |row, index|
          remaining_rows = rows.count - index
          if remaining_rows % 100 == 0
            puts "#{remaining_rows} remaining rows to process in priority associations spreadsheet"
          end

          next if index == 0
          row = Row.new(
            row,
            priorities_list: priorities_list,
            row_number: index
          )
          next if row.data_missing?
          BudgetDataSaver.new(row).save_data
        end
      end
    end

    attr_reader :rows,
                :priorities_list
  end
end
