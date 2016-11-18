class Month < TimePeriod
  def initialize(year, month)
    @year = year
    @month = month
    @start_date = Date.new(year, month, 1).beginning_of_month if start_date.nil?
    @end_date = Date.new(year, month, 1).end_of_month if end_date.nil?
  end

  attr_reader :year, :month, :start_date, :end_date

  def self.between_dates(start_date, end_date)
    @start_date = start_date
    @end_date = end_date

    raise dates_not_valid_error unless dates_valid?(start_date, end_date)

    Month.new(start_date.year, start_date.month)
  end

  def self.dates_valid?(start_date, end_date)
    return false if start_date.month != end_date.month
    return false if start_date != start_date.beginning_of_month
    return false if end_date != end_date.end_of_month

    true
  end

  def self.for_date(date)
    Month.new(date.year, date.month)
  end

  def strftime(format_str)
    start_date.strftime(format_str)
  end

  def <=>(another_month)
    if start_date < another_month.start_date
      return -1
    elsif start_date > another_month.start_date
      return 1
    else
      return 0
    end
  end

  def ==(o)
    self.class == o.class && state == o.state
  end

  def state
    [start_date, end_date]
  end

  def next
    Month.for_date(start_date.next_month)
  end

  def previous
    Month.for_date(start_date - 1)
  end

  def to_hash
    {
      start_date: start_date,
      end_date: end_date
    }
  end

  def to_s
    "#{I18n.t('date.month_names')[to_i]}, #{year}"
  end

  private

  def to_i
    start_date.month
  end

  def dates_valid?
    Month.dates_valid?(start_date, end_date)
  end

  def self.dates_not_valid_error
    'Dates must be first and last day of same month'
  end
end
