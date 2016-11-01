module MonthlyBudgetSheet
  class Item
    def initialize(rows, args)
      @rows = rows
      @budget_item = nil
      @start_date = args[:start_date]
      @warnings = []
      @item_is_new = nil
    end

    def save
      return unless klass.present?

      self.budget_item = budget_item_object

      # There is only one Total method with only one name
      if klass == Total
        budget_item.add_name(
          text_en: 'Total Georgian Budget',
          text_ka: 'მთლიანი სახელმწიფო ბიუჯეტი',
          start_date: start_date
        )
      else
        # if the new name is a duplicate of another name, then the names
        # will be merged in an after commit callback
        budget_item.add_name(
          nameable: budget_item,
          text: name,
          start_date: start_date
        )
      end

      if spent_finance_amount.present?
        SpentFinance.create(
          time_period: month,
          finance_spendable: budget_item,
          amount: spent_finance_amount
        )
      else
        add_warning 'Could not get the spent finance amount'
      end

      if planned_finance_amount.present?
        budget_item.add_planned_finance(
          time_period: quarter,
          announce_date: start_date,
          amount: planned_finance_amount
        )
      else
        add_warning 'Could not get the planned finance amount'
      end

      if item_is_new && budget_item.respond_to?(:save_possible_duplicates)
        budget_item.save_possible_duplicates
      end

      output_warnings
    end

    def budget_item_object
      item = get_saved_budget_item
      if item.present?
        self.item_is_new = false
        return item
      end

      self.item_is_new = true
      item = klass.create(code: primary_code)

      item
    end

    attr_accessor :rows, :budget_item, :start_date, :warnings, :item_is_new

    private

    def get_saved_budget_item
      return Total.first if klass == Total

      item = klass.where(code: primary_code).find do |possible_item|
        possible_item.name == name
      end

      return item if item.present?
      nil
    end

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
      return nil unless cumulative_spent_finance_amount.present?

      cumulative_spent_finance_amount - previously_spent
    end

    def planned_finance_amount
      previously_spent = budget_item.planned_finances.year_cumulative_up_to(start_date)
      return nil unless cumulative_planned_finance_amount.present?

      cumulative_planned_finance_amount - previously_spent
    end

    def cumulative_spent_finance_amount
      totals_row.spent_finance
    end

    def cumulative_planned_finance_amount
      totals_row.planned_finance
    end

    def name
      header_row.name.gsub('–', '-')
    end

    def primary_code
      header_row.code
    end

    def header_row
      rows.find(&:is_header?)
    end

    def totals_row
      rows.find(&:is_totals_row?)
    end

    def add_warning(msg)
      warnings << msg
    end

    def output_warnings
      return if warnings.empty?

      puts "\nWarnings for budget item between rows #{starting_row_num} and #{last_row_num}"
      warnings.each { |warning| puts "WARNING: #{warning}" }
    end

    def starting_row_num
      header_row.data.r
    end

    def last_row_num
      rows.last.data.r
    end
  end
end
