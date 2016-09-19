class HighchartsTimeSeries
  def initialize(unformatted_data)
    @unformatted_data = unformatted_data
  end

  def data
    {
      time_periods: time_period_months,
      amounts: amounts
    }
  end

  attr_reader :unformatted_data

  private

  def amounts
    unformatted_data.map(&:amount)
  end

  def time_period_months
    time_periods.map(&:month)
  end

  def time_periods
    unformatted_data.map do |data_point|
      TimePeriod.new(data_point.start_date, data_point.end_date)
    end
  end
end
