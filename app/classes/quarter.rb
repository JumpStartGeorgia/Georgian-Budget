class Quarter
  def initialize(start_date, end_date)
    @start_date = start_date
    @end_date = end_date
    @year = start_date.year

    raise 'Dates must be first and last day of a quarter' unless dates_valid?
  end

  attr_reader :start_date, :end_date, :year

  def self.for_date(date)
    start_date = start_date_for_date(date)
    end_date = end_date_for_date(date)

    Quarter.new(start_date, end_date)
  end

  def to_hash
    {
      start_date: start_date,
      end_date: end_date
    }
  end

  def to_i
    return 1 if start_date < Quarter.valid_start_dates(start_date.year)[1]
    return 2 if start_date < Quarter.valid_start_dates(start_date.year)[2]
    return 3 if start_date < Quarter.valid_start_dates(start_date.year)[3]
    return 4
  end

  def to_s
    I18n.t("shared.time_periods.quarter_#{to_i}", year: year)
  end

  def self.dates_valid?(start_date, end_date)
    return false unless valid_start_dates(start_date.year).include?(start_date)
    return false unless valid_end_dates(end_date.year).include?(end_date)

    true
  end

  def <=>(other_quarter)
    return -1 if start_date < other_quarter.start_date
    return 0 if start_date == other_quarter.start_date
    return 1
  end

  def ==(other_quarter)
    return false if start_date != other_quarter.start_date
    true
  end

  def next
    new_month = (start_date.month + 3)%12
    new_year = start_date.year + (start_date.month + 3)/12

    Quarter.for_date(Date.new(new_year, new_month, 1))
  end

  private

  def dates_valid?
    Quarter.dates_valid?(start_date, end_date)
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
