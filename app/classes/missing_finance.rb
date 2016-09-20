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

  attr_reader :start_date, :end_date

  def amount
    nil
  end
end
