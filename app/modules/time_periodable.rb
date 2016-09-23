module TimePeriodable
  def month
    Month.between_dates(start_date, end_date)
  end

  def time_period_class
    return Month if Month.dates_valid?(start_date, end_date)
    return Quarter if Quarter.dates_valid?(start_date, end_date)

    nil
  end

  def time_period
    if time_period_class == Month
      return time_period_class.between_dates(start_date, end_date)
    else
      return time_period_class.new(start_date, end_date)
    end
  end

  def time_period=(time_period)
    self.start_date = time_period.start_date
    self.end_date = time_period.end_date
  end
end
