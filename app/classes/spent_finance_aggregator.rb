class SpentFinanceAggregator
  def create_from_monthly(time_period_klass)
    budget_items.each do |budget_item|
      new_finance_time_periods(
        time_period_klass,
        budget_item
      ).each do |new_time_period|
        budget_item.add_spent_finance(
          time_period_obj: new_time_period,
          amount: amount_for_new_finance(budget_item, new_time_period),
          official: false)
      end
    end
  end

  private

  def budget_items
    SpentFinance
    .monthly
    .official
    .select(
      :finance_spendable_type,
      :finance_spendable_id)
    .group(
      :finance_spendable_type,
      :finance_spendable_id
    ).map(&:budget_item)
  end

  def new_finance_time_periods(time_period_klass, budget_item)
    time_period_klass
    .for_dates(
      budget_item
      .spent_finances
      .pluck(:start_date)
    )
  end

  def amount_for_new_finance(budget_item, new_time_period)
    calculators = monthly_official_spent_finances(
      budget_item,
      new_time_period
    )
    amount = calculators.sum(:amount)

    return nil if amount == 0.0 && calculators
      .where
      .not(amount: nil)
      .count == 0

    return amount
  end

  def monthly_official_spent_finances(budget_item, new_time_period)
    budget_item
      .spent_finances
      .monthly
      .official
      .after(new_time_period.start_date)
      .before(new_time_period.end_date)
  end
end
