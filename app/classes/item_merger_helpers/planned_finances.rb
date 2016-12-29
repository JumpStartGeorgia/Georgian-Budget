class ItemMergerHelpers::PlannedFinances
  attr_reader :receiver

  def initialize(receiver)
    @receiver = receiver
  end

  def merge(finances)
    return if finances.blank?

    first_new_quarter_plan = finances.quarterly.first

    cumulative_within_year = first_new_quarter_plan.blank? ? []
      : finances.with_time_period(first_new_quarter_plan.time_period_obj)

    finances.each do |new_planned_finance|
      calculate_cumulative = cumulative_within_year.include?(new_planned_finance)

      receiver.take_planned_finance(
        new_planned_finance,
        cumulative_within: calculate_cumulative ? Year : nil
      )
    end
  end
end
