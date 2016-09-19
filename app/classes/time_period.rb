class TimePeriod
  def initialize(start_date, end_date)
    @start_date = start_date
    @end_date = end_date
  end

  attr_reader :start_date, :end_date

  def month
    return nil if start_date != start_date.beginning_of_month
    return nil if end_date != end_date.end_of_month
    return nil if start_date.month != end_date.month

    return start_date.strftime('%B, %Y')
  end
end
