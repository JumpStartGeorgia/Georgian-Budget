class MonthlyBudgetSheetItem
  def initialize(rows)
    @rows = rows
  end

  def save_data
    header_row.save_data
  end

  private

  def header_row
    rows[0]
  end

  attr_reader :rows
end
