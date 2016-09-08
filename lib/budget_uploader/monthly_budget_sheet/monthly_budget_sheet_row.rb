class MonthlyBudgetSheetRow
  def initialize(row_data)
    @row_data = row_data
  end

  # if the first col is left aligned and the 3rd column is blank, this is a new item
  def is_item?
    return false if cells.empty?

    code_is_left_aligned && third_cell_is_empty
  end

  def code
    cells[0].value
  end

  def name
    cells[1].value
  end

  private

  def code_is_left_aligned
    cells[0].horizontal_alignment == 'left'
  end

  def third_cell_is_empty
    cells[2].nil? || cells[2].value.nil? || cells[2].value.strip == ''
  end

  def cells
    row_data.cells
  end

  attr_reader :row_data
end
