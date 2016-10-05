module MonthlyBudgetSheet
  class Item
    def initialize(rows, start_date, end_date)
      @rows = rows
      @budget_item = nil
      @start_date = start_date
      @end_date = end_date
    end

    def save
      return unless klass.present?

      self.budget_item = klass.find_by_code(primary_code)

      unless budget_item.present?
        self.budget_item = klass.create(code: primary_code)
      end

      # There is only one Total method with only one name
      if klass == Total
        Name.create(
          nameable: budget_item,
          text_en: 'Total Georgian Budget',
          text_ka: 'მთლიანი სახელმწიფო ბიუჯეტი',
          start_date: start_date
        )
      else
        # if the new name is a duplicate of another name, then the names
        # will be merged in an after commit callback
        Name.create(
          nameable: budget_item,
          text: name,
          start_date: start_date
        )
      end

      SpentFinance.create(
        time_period: month,
        finance_spendable: budget_item,
        amount: spent_finance_amount
      )

      budget_item.add_planned_finance(
        time_period: quarter,
        announce_date: start_date,
        amount: planned_finance_amount
      )
    end

    attr_accessor :rows, :budget_item, :start_date, :end_date

    private

    def klass
      BudgetCodeMapper.class_for_code(primary_code)
    end

    def month
      Month.for_date(start_date)
    end

    def quarter
      Quarter.for_date(start_date)
    end

    # The amounts recorded in the spreadsheets are cumulative within the year.
    # For example, the spent finance recorded for March is the total
    # spending of January, February and March, and the planned finance
    # recorded for Quarter 2 is the total planned amount for the first
    # two quarters.

    # We don't want to save the cumulative amount, so these methods
    # get the non-cumulative amounts.
    def spent_finance_amount
      previously_spent = budget_item.spent_finances.year_cumulative_up_to(start_date)
      cumulative_spent_finance_amount - previously_spent
    end

    def planned_finance_amount
      previously_spent = budget_item.planned_finances.year_cumulative_up_to(start_date)
      cumulative_planned_finance_amount - previously_spent
    end

    def cumulative_spent_finance_amount
      totals_row.spent_finance
    end

    def cumulative_planned_finance_amount
      totals_row.planned_finance
    end

    def name
      header_row.name
    end

    def primary_code
      header_row.code
    end

    def header_row
      rows[0]
    end

    def totals_row
      rows.find { |row| row.name == 'ჯამური' && !row.code_is_left_aligned }
    end
  end
end
