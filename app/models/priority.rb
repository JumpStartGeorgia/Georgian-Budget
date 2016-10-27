class Priority < ApplicationRecord
  include Codeable
  include Nameable
  include FinanceSpendable
  include FinancePlannable

  has_many :programs

  # Updates the priority's finances by summing the finance amounts of the
  # priority's programs.
  def update_finances
    update_spent_finances
    update_planned_finances
  end

  private

  def update_spent_finances
    program_spent_finances = SpentFinance.select(
      'SUM(amount) AS amount, start_date, end_date'
    ).where(
      finance_spendable: programs
    ).group(
      :start_date,
      :end_date
    )

    program_spent_finances.each do |program_spent_finance|
      SpentFinance.create(
        finance_spendable: self,
        time_period: program_spent_finance.time_period,
        amount: program_spent_finance.amount
      )
    end
  end

  def update_planned_finances
    # Get the unique time period and announce date combinations for
    # this priority's programs' planned finances.
    planned_finance_time_period_announce_dates = PlannedFinance.select(
      :start_date, :end_date, :announce_date
    ).where(finance_plannable: programs)
    .group(:start_date, :end_date, :announce_date)

    planned_finance_time_period_announce_dates.each do |dates_combo|
      program_planned_finances = PlannedFinance
      .select('DISTINCT ON (finance_plannable_type, finance_plannable_id, start_date, end_date) *')
      .where(finance_plannable: programs)
      .with_time_period(dates_combo.time_period)
      .where('announce_date <= ?', dates_combo.announce_date)
      .order(:finance_plannable_type, :finance_plannable_id, :start_date, :end_date, announce_date: :desc)

      amount = PlannedFinance.find(program_planned_finances.map(&:id)).map(&:amount).sum

      add_planned_finance(
        time_period: dates_combo.time_period,
        announce_date: dates_combo.announce_date,
        amount: amount)
    end
  end
end
