module TimePeriodable
  def month
    Month.between_dates(start_date, end_date)
  end

  def time_period_class
    return Month if Month.dates_valid?(start_date, end_date)
    return Quarter if Quarter.dates_valid?(start_date, end_date)

    nil
  end
end
