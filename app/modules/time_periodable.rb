module TimePeriodable
  def month
    Month.between_dates(start_date, end_date)
  end
end
