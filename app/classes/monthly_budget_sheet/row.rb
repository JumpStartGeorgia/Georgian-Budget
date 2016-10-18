module MonthlyBudgetSheet
  class Row
    def initialize(data, args = {})
      @data = data
      @code_column = args[:code_column] || 0
      @name_column = args[:name_column] || 1
      @spent_finance_column = args[:spent_finance_column] || 6
      @planned_finance_column = args[:planned_finance_column] || 2
    end

    # returns true if this is the header row of an item
    def is_header?
      return false unless contains_data?
      return false if spent_finance.present?
      return false if planned_finance.present?

      true
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
      value = planned_finance_cell.value
      return nil if value.to_s.empty?

      value.to_f
    end

    def planned_finance_cell
      cells[planned_finance_column]
    end

    def spent_finance
      value = spent_finance_cell.value
      return nil if value.to_s.empty?

      value.to_f
    end

    def spent_finance_cell
      cells[spent_finance_column]
    end

    def cells
      data.cells
    end

    attr_reader :data,
                :code_column,
                :name_column,
                :spent_finance_column,
                :planned_finance_column
  end
end
