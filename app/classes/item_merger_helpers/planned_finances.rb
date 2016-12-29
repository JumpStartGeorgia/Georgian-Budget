class ItemMergerHelpers::PlannedFinances
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
    receiver.take_planned_finance(
      finance,
      cumulative_within: cumulative_period_for(finance)
    )
  end

  # returns nil if it is not cumulative, otherwise Year
  def cumulative_period_for(finance)
    cumulative_finances.include?(finance) ? Year : nil
  end

  def cumulative_finances
    @cumulative_finances ||= get_cumulative_finances
  end

  def get_cumulative_finances
    first_finance = finances.quarterly.first

    first_finance.blank? ? []
      : finances.with_time_period(first_finance.time_period_obj)
  end
end
