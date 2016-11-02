module MonthlyBudgetSheet
  module NonCumulativeFinanceCalculator
    # The amounts recorded in the spreadsheets are cumulative within the year.
    # For example, the spent finance recorded for March is the total
    # spending of January, February and March, and the planned finance
    # recorded for Quarter 2 is the total planned amount for the first
    # two quarters.

    # We don't want to save the cumulative amount, so this method
    # gets the non-cumulative amount.
    def self.calculate(args)
      return nil if data_missing?(args)
      finances = args[:finances]
      start_date = args[:start_date]
      cumulative_amount = args[:cumulative_amount]

      previously_spent = finances.year_cumulative_up_to(start_date)
      cumulative_amount - previously_spent
    end

    private

    def self.data_missing?(args)
      return true if args[:finances].nil?
      return true if args[:start_date].blank?
      return true if args[:cumulative_amount].blank?

      false
    end
  end
end
