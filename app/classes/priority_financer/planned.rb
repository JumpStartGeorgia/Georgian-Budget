class PriorityFinancer::Planned
  attr_reader :priority

  def initialize(priority)
    @priority = priority
  end

  def update_from(planned_finances)
    planned_finances
    .select(:start_date, :end_date, :announce_date, :time_period_type)
    .group(:start_date, :end_date, :announce_date, :time_period_type)
    .each do |plan_grouped_by_dates|
      create_planned_finance(plan_grouped_by_dates, planned_finances)
    end
  end

  private

  def create_planned_finance(dates, planned_finances)
    priority.add_planned_finance(
      time_period_obj: dates.time_period_obj,
      announce_date: dates.announce_date,
      amount: planned_finance_amount_for_dates(dates, planned_finances),
      official: false)
  end

  def planned_finance_amount_for_dates(dates, planned_finances)
    program_planned_finance_ids = planned_finances
    .select('DISTINCT ON (finance_plannable_type, finance_plannable_id, start_date, end_date) id')
    .with_time_period(dates.time_period_obj)
    .where('announce_date <= ?', dates.announce_date)
    .order(:finance_plannable_type, :finance_plannable_id, :start_date, :end_date, announce_date: :desc)
    .map(&:id)

    amounts = PlannedFinance.find(program_planned_finance_ids).map(&:amount)

    if amounts.length == 1
      return amounts[0]
    elsif amounts.select(&:present?).empty?
      return nil
    else
      return amounts.select { |amount| amount.present? }.sum
    end
  end
end
