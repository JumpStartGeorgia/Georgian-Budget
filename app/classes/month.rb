class Month
  def initialize(year, month)
    @year = year
    @month = month
    @start_date = Date.new(year, month, 1).beginning_of_month if start_date.nil?
    @end_date = Date.new(year, month, 1).end_of_month if end_date.nil?
  end

  attr_reader :year, :month, :start_date, :end_date

  def self.between_dates(start_date, end_date)
    raise dates_not_valid_error if start_date.month != end_date.month
    raise dates_not_valid_error if start_date != start_date.beginning_of_month
    raise dates_not_valid_error if end_date != end_date.end_of_month

    @start_date = start_date
    @end_date = end_date

    Month.new(start_date.year, start_date.month)
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

  def ==(another_month)
    if start_date == another_month.start_date
      return true
    else
      return false
    end
  end

  private

  def self.dates_not_valid_error
    'Dates must be first and last day of same month'
  end
end
