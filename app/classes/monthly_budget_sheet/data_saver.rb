module MonthlyBudgetSheet
  class DataSaver
    def initialize
    end

    def save_data_from_monthly_sheet_item(monthly_sheet_item)
      extract_monthly_sheet_item_args(monthly_sheet_item)

      return unless budget_item.present?

      save_name
      save_spent_finance
      save_planned_finance

      if budget_item.respond_to?(:save_possible_duplicates)
        budget_item.save_possible_duplicates
      end

      output_warnings
    end

    def budget_item
      @budget_item ||= BudgetItemFetcher.new.fetch(
        create_if_nil: true,
        code_number: primary_code,
        name_text: name_text
      )
    end

    attr_accessor :item_is_new,
                  :start_date,
                  :primary_code,
                  :name_text,
                  :spent_finance_cumulative,
                  :planned_finance_cumulative,
                  :warnings

    private

    def item_is_new
      budget_item.recent_name_object.start_date == start_date
    end

    def extract_monthly_sheet_item_args(monthly_sheet_item)
      self.start_date = monthly_sheet_item.start_date
      self.primary_code = monthly_sheet_item.primary_code
      self.name_text = monthly_sheet_item.name_text
      self.spent_finance_cumulative = monthly_sheet_item.spent_finance_cumulative
      self.planned_finance_cumulative = monthly_sheet_item.planned_finance_cumulative
      self.warnings = monthly_sheet_item.warnings
    end

    def save_name
      # There is only one Total method with only one name
      if budget_item.class == Total
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
          text: name_text,
          start_date: start_date
        )
      end
    end

    def save_spent_finance
      if spent_finance_amount.present?
        budget_item.add_spent_finance(
          time_period: month,
          amount: spent_finance_amount
        )
      else
        add_warning 'Could not get the spent finance amount'
      end
    end

    def save_planned_finance
      if planned_finance_amount.present?
        budget_item.add_planned_finance(
          time_period: quarter,
          announce_date: start_date,
          amount: planned_finance_amount
        )
      else
        add_warning 'Could not get the planned finance amount'
      end
    end

    # The amounts recorded in the spreadsheets are cumulative within the year.
    # For example, the spent finance recorded for March is the total
    # spending of January, February and March, and the planned finance
    # recorded for Quarter 2 is the total planned amount for the first
    # two quarters.

    # We don't want to save the cumulative amount, so these methods
    # get the non-cumulative amounts.
    def spent_finance_amount
      return nil unless spent_finance_cumulative.present?

      previously_spent = budget_item.spent_finances.year_cumulative_up_to(start_date)
      spent_finance_cumulative - previously_spent
    end

    def planned_finance_amount
      return nil unless planned_finance_cumulative.present?

      previously_spent = budget_item.planned_finances.year_cumulative_up_to(start_date)
      planned_finance_cumulative - previously_spent
    end

    def month
      Month.for_date(start_date)
    end

    def quarter
      Quarter.for_date(start_date)
    end

    def add_warning(msg)
      warnings << msg
    end

    def output_warnings
      return if warnings.empty?

      puts "\nWarnings for budget item between rows #{starting_row_num} and #{last_row_num}"
      warnings.each { |warning| puts "WARNING: #{warning}" }
    end
  end
end
