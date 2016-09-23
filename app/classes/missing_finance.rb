class MissingFinance
  include TimePeriodable

  def initialize(args)
    if args[:start_date].nil?
      raise 'MissingFinance must be initialized with a start date'
    end

    if args[:end_date].nil?
      raise 'MissingFinance must be initialized with an end date'
    end

    @start_date = args[:start_date]
    @end_date = args[:end_date]
  end

  def ==(other_missing_finance)
    return false if other_missing_finance.nil?
    return false if start_date != other_missing_finance.start_date
    return false if end_date != other_missing_finance.end_date

    return true
  end

  attr_reader :start_date, :end_date

  def amount
    nil
  end
end
