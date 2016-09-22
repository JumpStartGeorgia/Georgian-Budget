class MonthlyBudgetSheetItem
  def initialize(rows)
    @rows = rows
    @budget_item = nil
  end

  def save(start_date, end_date)
    budget_item_class = BudgetCodeMapper.class_for_code(primary_code)

    return unless budget_item_class.present?

    budget_item = budget_item_class.find_by_code(primary_code)

    unless budget_item.present?
      budget_item = budget_item_class.create(code: primary_code)
    end

    # There is only one Total method with only one name
    if budget_item_class == Total
      Name.create(
        nameable: budget_item,
        text_en: 'Total Georgian Budget',
        text_ka: 'მთლიანი სახელმწიფო ბიუჯეტი',
        start_date: start_date
      )
    else
      # if the new name is a duplicate of another name, then the names
      # will be merged in an after commit callback
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
      amount: spent_finance_amount(budget_item, start_date)
    )

    #
    # PlannedFinance.create(
    #   amount: planned_finance_amount
    # )
  end

  attr_accessor :rows, :budget_item

  private

  def spent_finance_amount(budget_item, start_date)
    previously_spent = budget_item.spent_finances.year_cumulative_up_to(start_date)
    cumulative_spent_finance_amount - previously_spent
  end

  def cumulative_spent_finance_amount
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
    rows.find { |row| row.name == 'ჯამური' && !row.code_is_left_aligned }
  end
end
