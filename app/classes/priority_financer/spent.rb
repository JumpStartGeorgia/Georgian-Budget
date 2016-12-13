class PriorityFinancer::Spent
  attr_reader :priority

  def initialize(priority)
    @priority = priority
  end

  def update_from(spent_finances)
    summed_finances = spent_finances.group(
      :start_date,
      :end_date,
      :time_period_type
    ).select(
      'SUM(amount) AS amount, start_date, end_date, time_period_type'
    )

    summed_finances.each do |summed_finance|
      priority.add_spent_finance(
        time_period_obj: summed_finance.time_period_obj,
        amount: summed_finance.amount,
        official: false)
    end
  end
end
