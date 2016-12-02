# The amounts recorded in monthly spreadsheets are cumulative within the year.
# For example, the spent finance recorded for March is the total
# spending of January, February and March, and the planned finance
# recorded for Quarter 2 is the total planned amount for the first
# two quarters.

# We don't want to save the cumulative amount, so the calculate method
# of this class gets the non cumulative amount.
class NonCumulativeFinanceCalculator
  def initialize(args)
    @finances = args[:finances]
    @cumulative_amount = args[:cumulative_amount]
    @time_period = args[:time_period_obj]
    @surrounding_time_period = args[:cumulative_within].for_date(
      time_period.start_date)
  end

  def calculate
    return nil if data_missing?

    previously_spent = finances
    .where(time_period_type: time_period.type)
    .after(surrounding_time_period.start_date)
    .before(time_period.previous.end_date)
    .total

    cumulative_amount - previously_spent
  end

  private

  attr_reader :finances,
              :cumulative_amount,
              :time_period,
              :surrounding_time_period

  def data_missing?
    return true if finances.nil?
    return true if cumulative_amount.blank?
    return true if time_period.blank?
    return true if surrounding_time_period.blank?

    false
  end
end
