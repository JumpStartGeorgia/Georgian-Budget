module MonthlyBudgetSheet
  class Row
    def initialize(data, args = {})
      @data = data
      @code_column = args[:code_column]
      @name_column = args[:name_column]
      @spent_finance_column = args[:spent_finance_column]
      @planned_finance_column = args[:planned_finance_column]
    end

    # returns true if this is the header row of an item
    def is_header?
      return false unless contains_data?
      return false if spent_finance.present?
      return false if planned_finance.present?

      true
    end

    def is_totals_row?
      name == 'ჯამური' && !is_header?
    end

    def contains_column_names?
      return false unless contains_value?('დ ა ს ა ხ ე ლ ე ბ ა')

      true
    end

    def contains_value?(value)
      cell_values.include?(value)
    end

    def column_number_for_values(values)
      values.each do |value|
        column = column_number_for_value(value)
        return column if column.present?
      end

      nil
    end

    # Find the cell containing a certain value, and return that cell's column
    # number. If none of the cells exist, return nil
    def column_number_for_value(value)
      cell = cells.find { |cell| clean_cell_value(cell) == value }
      cell.present? ? cell.column : nil
    end

    # returns true if item has code and name
    def contains_data?
      return false if cells.empty?
      return false if code.nil? || code.empty?
      return false if name.nil? || name.empty?

      true
    end

    def code
      return nil if cells.empty?
      return nil if code_cell.nil?
      value = code_cell.value

      return nil if value.nil?
      value.to_s.strip
    end

    def code_cell
      cells[code_column]
    end

    def name
      return nil if cells.empty?
      return nil if name_cell.nil?
      value = name_cell.value

      return nil if value.nil?
      value.to_s.strip
    end

    def name_cell
      cells[name_column]
    end

    def planned_finance
      return nil if planned_finance_cell.nil?
      value = planned_finance_cell.value
      return nil if value.to_s.empty?

      value.to_f
    end

    def planned_finance_cell
      cells[planned_finance_column]
    end

    def spent_finance
      return nil if spent_finance_cell.nil?
      value = spent_finance_cell.value
      return nil if value.to_s.empty?

      value.to_f
    end

    def spent_finance_cell
      cells[spent_finance_column]
    end

    def cells
      @cells ||= data.cells
    end

    attr_reader :data,
                :code_column,
                :name_column,
                :spent_finance_column,
                :planned_finance_column

    private

    def cell_values
      @cell_values ||= cells.map do |cell|
        clean_cell_value(cell)
      end
    end

    def clean_cell_value(cell)
      return nil unless cell.present?
      value = cell.value

      return nil unless value.present?
      return value unless value.is_a? String

      value.strip().gsub(/\s+/, ' ')
    end
  end
end
