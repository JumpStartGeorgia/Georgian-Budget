module NonCumulativeFinanceCalculator
  def self.calculate(args)
    return nil if data_missing?(args)
    finances = args[:finances]
    start_date = args[:start_date]
    cumulative_amount = args[:cumulative_amount]

    previously_spent = finances.year_cumulative_up_to(start_date)
    cumulative_amount - previously_spent
  end

  def self.data_missing?(args)
    return true if args[:finances].nil?
    return true if args[:start_date].blank?
    return true if args[:cumulative_amount].blank?

    false
  end
end
