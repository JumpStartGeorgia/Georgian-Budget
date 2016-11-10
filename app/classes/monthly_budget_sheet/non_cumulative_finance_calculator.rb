module MonthlyBudgetSheet
  class NonCumulativeFinanceCalculator
    # The amounts recorded in monthly spreadsheets are cumulative within the year.
    # For example, the spent finance recorded for March is the total
    # spending of January, February and March, and the planned finance
    # recorded for Quarter 2 is the total planned amount for the first
    # two quarters.

    # We don't want to save the cumulative amount, so this method
    # gets the non-cumulative amount.

    def initialize(args)
      @finances = args[:finances]
      @start_date = args[:start_date]
      @cumulative_amount = args[:cumulative_amount]
    end

    def calculate
      return nil if data_missing?

      previously_spent = finances.after(Date.new(start_date.year, 1, 1)).before(start_date).total
      cumulative_amount - previously_spent
    end

    private

    attr_reader :finances,
                :start_date,
                :cumulative_amount

    def data_missing?
      return true if finances.nil?
      return true if start_date.blank?
      return true if cumulative_amount.blank?

      false
    end
  end
end
