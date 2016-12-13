class PriorityFinancer::Spent
  attr_reader :priority

  def initialize(priority)
    @priority = priority
  end

  def update_spent_finances
    program_spent_finances = SpentFinance.select(
      'SUM(amount) AS amount, start_date, end_date, time_period_type'
    ).where(
      finance_spendable: priority.programs
    ).group(
      :start_date,
      :end_date,
      :time_period_type
    )

    program_spent_finances.each do |program_spent_finance|
      priority.add_spent_finance(
        time_period_obj: program_spent_finance.time_period_obj,
        amount: program_spent_finance.amount,
        official: false)
    end
  end
end
