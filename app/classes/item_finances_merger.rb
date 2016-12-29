class ItemFinancesMerger
  attr_reader :receiver, :finances

  def initialize(receiver, finances)
    @receiver = receiver
    @finances = finances
  end

  def merge
    return if finances.blank?

    finances.each do |finance|
      receiver_take(finance)
    end
  end

  private

  def receiver_take(finance)
    if finances_model == PlannedFinance
      receiver.take_planned_finance(
        finance,
        cumulative_within: cumulative_period_for(finance)
      )
    elsif finances_model == SpentFinance
      receiver.take_spent_finance(
        finance,
        cumulative_within: cumulative_period_for(finance)
      )
    end
  end

  # returns nil if it is not cumulative, otherwise Year
  def cumulative_period_for(finance)
    cumulative_finances.include?(finance) ? Year : nil
  end

  def cumulative_finances
    @cumulative_finances ||= get_cumulative_finances
  end

  def get_cumulative_finances
    if first_cumulative_time_period.blank?
      []
    else
      finances.with_time_period(first_cumulative_time_period.time_period_obj)
    end
  end

  def first_cumulative_time_period
    @first_cumulative_time_period ||= get_first_cumulative_time_period
  end

  def get_first_cumulative_time_period
    if finances_model == PlannedFinance
      finances.quarterly.first
    elsif finances_model == SpentFinance
      finances.monthly.first
    end
  end

  def finances_model
    finances.model
  end
end
