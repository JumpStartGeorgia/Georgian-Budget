class SpentFinanceAggregator
  def create_from_monthly(time_period_klass)
    finance_spendables = SpentFinance
      .monthly
      .select(
        :finance_spendable_type,
        :finance_spendable_id)
      .group(
        :finance_spendable_type,
        :finance_spendable_id
      )

    finance_spendables.each do |finance_spendables|
      finance_spendable = finance_spendables.finance_spendable

      new_time_periods = time_period_klass.for_dates(
        finance_spendable.spent_finances.pluck(:start_date))

      new_time_periods.each do |new_time_period|
        monthly_official_spent_finances = finance_spendable
          .spent_finances
          .monthly
          .official
          .after(new_time_period.start_date)
          .before(new_time_period.end_date)

        amount = monthly_official_spent_finances.sum(:amount)

        amount = nil if amount == 0.0 && monthly_official_spent_finances.where.not(amount: nil)
          .count == 0

        finance_spendable.add_spent_finance(
          time_period_obj: new_time_period,
          amount: amount,
          official: false)
      end
    end
  end
end
