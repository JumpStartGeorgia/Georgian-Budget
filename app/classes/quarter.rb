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
    end_date = end_date_for_start_date(start_date)

    Quarter.new(start_date, end_date)
  end

  def to_hash
    {
      start_date: start_date,
      end_date: end_date
    }
  end

  def to_i
    return start_date.month/3 + 1
  end

  def to_s
    I18n.t("shared.time_periods.quarter_#{to_i}", year: year)
  end

  def <=>(other_quarter)
    return -1 if start_date < other_quarter.start_date
    return 0 if start_date == other_quarter.start_date
    return 1
  end

  def ==(other_quarter)
    other_quarter.class == self.class && other_quarter.state == state
  end

  alias_method :eql?, :==

  def next
    new_month = (start_date.month + 3)%12
    new_year = start_date.year + (start_date.month + 3)/12

    Quarter.for_date(Date.new(new_year, new_month, 1))
  end

  def previous
    Quarter.for_date(start_date - 1)
  end

  def self.dates_valid?(start_date, end_date)
    return false unless start_date.day == 1
    return false unless [1, 4, 7, 10].include? start_date.month
    return false unless end_date == end_date_for_start_date(start_date)

    true
  end

  def self.for_dates(dates)
    dates.map { |date| for_date(date) }.uniq
  end

  def hash
    state.hash
  end

  def state
    [start_date, end_date]
  end

  private

  def dates_valid?
    Quarter.dates_valid?(start_date, end_date)
  end

  def self.start_date_for_date(date)
    modifier = case date.month % 3
    when 0
      -2
    when 1
      0
    when 2
      -1
    end

    month = date.month + modifier

    return Date.new(date.year, month, 1)
  end

  def self.end_date_for_start_date(start_date)
    (start_date + 70).end_of_month
  end
end
