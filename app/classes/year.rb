class Year < TimePeriod
  def initialize(year_num)
    @start_date = Date.new(year_num, 1, 1)
    @end_date = Date.new(year_num, 12, 31)
  end

  def self.for_date(date)
    new(date.year)
  end

  def self.for_dates(dates)
    dates.map { |date| for_date(date) }.uniq
  end

  def self.dates_valid?(start_date, end_date)
    return false unless start_date.month == 1
    return false unless start_date.day == 1
    return false unless end_date.month == 12
    return false unless end_date.day == 31
    return false unless start_date.year == end_date.year

    true
  end

  def next
    Year.new(start_date.year + 1)
  end

  def previous
    Year.new(start_date.year - 1)
  end

  def to_hash
    {
      start_date: start_date,
      end_date: end_date
    }
  end

  def ==(o)
    self.class == o.class && self.state == o.state
  end
  alias_method :eql?, :==

  def state
    [start_date, end_date]
  end

  def hash
    state.hash
  end

  def to_s
    start_date.year.to_s
  end

  attr_reader :start_date, :end_date
end
