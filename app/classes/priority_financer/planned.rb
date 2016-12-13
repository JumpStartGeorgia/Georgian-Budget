class PriorityFinancer::Planned
  attr_reader :priority

  def initialize(priority)
    @priority = priority
  end

  def update_planned_finances
    # Get the unique time period and announce date combinations for
    # this priority's programs' planned finances.
    planned_finance_time_period_announce_dates = PlannedFinance.select(
      :start_date, :end_date, :announce_date, :time_period_type
    ).where(finance_plannable: priority.programs)
    .group(:start_date, :end_date, :announce_date, :time_period_type)

    planned_finance_time_period_announce_dates.each do |new_planned_finance_dates|
      create_planned_finance_with_dates(new_planned_finance_dates)
    end
  end

  private

  def create_planned_finance_with_dates(dates)
    priority.add_planned_finance(
      time_period_obj: dates.time_period_obj,
      announce_date: dates.announce_date,
      amount: planned_finance_amount_for_dates(dates),
      official: false)
  end

  def planned_finance_amount_for_dates(dates)
    program_planned_finance_ids = PlannedFinance
    .select('DISTINCT ON (finance_plannable_type, finance_plannable_id, start_date, end_date) id')
    .where(finance_plannable: priority.programs)
    .with_time_period(dates.time_period_obj)
    .where('announce_date <= ?', dates.announce_date)
    .order(:finance_plannable_type, :finance_plannable_id, :start_date, :end_date, announce_date: :desc)
    .map(&:id)

    amounts = PlannedFinance.find(program_planned_finance_ids).map(&:amount)

    if amounts.length == 1
      return amounts[0]
    else
      return amounts.select { |amount| amount.present? }.sum
    end
  end
end
