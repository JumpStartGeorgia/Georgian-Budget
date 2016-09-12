class MonthlyBudgetSheetItem
  def initialize(rows, start_date)
    @rows = rows
    @start_date = start_date
  end

  def save
    budget_item_class = BudgetCodeMapper.class_for_code(primary_code)

    return unless budget_item_class.present?
    return if budget_item_class.find_by_name(name).present?

    budget_item = budget_item_class.create

    Name.create(
      nameable: budget_item,
      text: name,
      start_date: start_date
    )

    # SpentFinance.create(
    #   amount: spent_finance_amount
    # )
    #
    # PlannedFinance.create(
    #   amount: planned_finance_amount
    # )
  end

  attr_accessor :rows

  private

  attr_reader :start_date

  def spent_finance_amount
    totals_row.spent_finance
  end

  def planned_finance_amount
    totals_row.planned_finance
  end

  def name
    header_row.name
  end

  def primary_code
    header_row.code
  end

  def header_row
    rows[0]
  end

  def totals_row
    rows.find { |row| row.name == 'ჯამური' }
  end
end
