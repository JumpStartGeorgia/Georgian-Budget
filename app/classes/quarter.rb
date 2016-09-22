class Quarter
  def initialize(start_date, end_date)
    @start_date = start_date
    @end_date = end_date
    @year = start_date.year

    unless dates_valid?
      raise 'Dates must be first and last day of a quarter'
    end
  end

  attr_reader :start_date, :end_date, :year

  def self.for_date(date)
    start_date = start_date_for_date(date)
    end_date = end_date_for_date(date)

    Quarter.new(start_date, end_date)
  end

  private

  def dates_valid?
    return false unless Quarter.valid_start_dates(year).include?(start_date)
    return false unless Quarter.valid_end_dates(year).include?(end_date)

    true
  end

  def self.valid_start_dates(year)
    [
      Date.new(year, 1, 1),
      Date.new(year, 4, 1),
      Date.new(year, 7, 1),
      Date.new(year, 10, 1)
    ]
  end

  def self.valid_end_dates(year)
    [
      Date.new(year, 3, 1).end_of_month,
      Date.new(year, 6, 1).end_of_month,
      Date.new(year, 9, 1).end_of_month,
      Date.new(year, 12, 1).end_of_month
    ]
  end

  def self.start_date_for_date(date)
    if date.month < 4
      return valid_start_dates(date.year)[0]
    elsif date.month < 7
      return valid_start_dates(date.year)[1]
    elsif date.month < 10
      return valid_start_dates(date.year)[2]
    else
      return valid_start_dates(date.year)[3]
    end
  end

  def self.end_date_for_date(date)
    if date < Date.new(date.year, 4, 1)
      return Date.new(date.year, 3, 1).end_of_month
    elsif date < Date.new(date.year, 7, 1)
      return Date.new(date.year, 6, 1).end_of_month
    elsif date < Date.new(date.year, 10, 1)
      return Date.new(date.year, 9, 1).end_of_month
    else
      return Date.new(date.year, 12, 1).end_of_month
    end
  end
end
