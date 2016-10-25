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
      rows.each_with_index do |row, index|
        next if index == 0
        Row.new(
          row,
          priorities_list: priorities_list,
          row_number: index
        ).save
      end
    end

    attr_reader :rows,
                :priorities_list
  end
end
