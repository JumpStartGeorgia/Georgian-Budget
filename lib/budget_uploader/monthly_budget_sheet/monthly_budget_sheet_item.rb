class MonthlyBudgetSheetItem
  def initialize(rows)
    @rows = rows
  end

  def save(start_date, end_date)
    budget_item_class = BudgetCodeMapper.class_for_code(primary_code)

    return unless budget_item_class.present?

    budget_item = budget_item_class.find_by_name(name)[0]

    unless budget_item.present? # do not create new item and new name if budget item is present
      budget_item = budget_item_class.create

      Name.create(
        nameable: budget_item,
        text: name,
        start_date: start_date
      )
    end


    SpentFinance.create(
      finance_spendable: budget_item,
      start_date: start_date,
      end_date: end_date,
      amount: spent_finance_amount
    )
    #
    # PlannedFinance.create(
    #   amount: planned_finance_amount
    # )
  end

  attr_accessor :rows

  private

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
