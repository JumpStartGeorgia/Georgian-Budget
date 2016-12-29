class ItemFinancesMerger
  attr_reader :receiver, :giver, :finances_model

  def initialize(receiver, giver, finances_model)
    @receiver = receiver
    @giver = giver
    @finances_model = finances_model
  end

  def merge
    finances.each do |finance|
      if cumulative_finances.include?(finance)
        update_amount_to_non_cumulative(finance)
      end
    end

    finances.each do |finance|
      receiver_take(finance)
    end
  end

  private

  def update_amount_to_non_cumulative(finance)
    finance.update_attributes!(
      amount: NonCumulativeFinanceCalculator.new(
        finances: primary_finances_of_receiver,
        cumulative_amount: finance.amount,
        time_period_obj: finance.time_period_obj,
        cumulative_within: Year
      ).calculate
    )
  end

  def primary_finances_of_receiver
    if finances_model == PlannedFinance
      return receiver.planned_finances
    elsif finances_model == SpentFinance
      return receiver.spent_finances
    end
  end

  def receiver_take(finance)
    if finances_model == PlannedFinance
      receiver.take_planned_finance(finance)
    elsif finances_model == SpentFinance
      receiver.take_spent_finance(finance)
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

  def finances
    @finances ||= get_finances
  end

  def get_finances
    if finances_model == PlannedFinance
      giver.all_planned_finances
    elsif finances_model == SpentFinance
      giver.all_spent_finances
    end
  end
end
