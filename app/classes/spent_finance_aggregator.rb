class SpentFinanceAggregator
  def create_quarterly_from_monthly
    finance_spendables = SpentFinance
      .monthly
      .select(
        :finance_spendable_type,
        :finance_spendable_id
      ).group(
        :finance_spendable_type,
        :finance_spendable_id
      )

    finance_spendables.each do |finance_spendables|
      finance_spendable = finance_spendables.finance_spendable

      quarters = Quarter.for_dates(
        finance_spendable.spent_finances.pluck(:start_date))

      quarters.each do |quarter|
        amount = finance_spendable
          .spent_finances
          .after(quarter.start_date)
          .before(quarter.end_date)
          .sum(:amount)

        amount = nil if amount == 0.0 && finance_spendable
          .spent_finances
          .where.not(amount: nil)
          .count == 0

        finance_spendable.add_spent_finance(
          time_period: quarter,
          amount: amount)
      end
    end
  end
end
