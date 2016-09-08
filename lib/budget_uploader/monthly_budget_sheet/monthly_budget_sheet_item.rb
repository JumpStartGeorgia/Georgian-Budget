class MonthlyBudgetSheetItem
  def initialize(rows)
    @rows = rows
  end

  def save
    budget_item_class = BudgetCodeMapper.class_for_code(primary_code)

    return unless budget_item_class.present?

    return if budget_item_class.find_by_name(name).present?

    budget_item = budget_item_class.create

    Name.create(
      nameable: budget_item,
      text: name,
      start_date: Date.today
    )
  end

  private

  def name
    header_row.name
  end

  def primary_code
    header_row.code
  end

  def header_row
    rows[0]
  end

  attr_reader :rows
end
