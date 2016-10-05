module MonthlyBudgetSheet
  class Row
    def initialize(data)
      @data = data
    end

    # returns true if this is the header row of an item
    def is_header?
      return false unless contains_data?

      code_is_left_aligned && third_cell_is_empty
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
      cells[0]
    end

    def name
      return nil if cells.empty?
      name_cell = cells[1]

      return nil if name_cell.nil?
      value = name_cell.value

      return nil if value.nil?
      value.to_s.strip
    end

    def planned_finance
      cells[2].value.to_f
    end

    def spent_finance
      cells[6].value.to_f
    end

    def code_is_left_aligned
      cells[0].horizontal_alignment == 'left'
    end

    def cells
      data.cells
    end

    attr_reader :data

    private

    def third_cell_is_empty
      cells[2].nil? || cells[2].value.nil? || cells[2].value.strip == ''
    end
  end
end
