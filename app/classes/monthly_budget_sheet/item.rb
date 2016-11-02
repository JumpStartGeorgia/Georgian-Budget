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

      DataSaver.new.save_data(
        budget_item: budget_item,
        start_date: start_date,
        spent_finance_cumulative: cumulative_spent_finance_amount,
        planned_finance_cumulative: cumulative_planned_finance_amount,
        warnings: warnings
      )

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
        Name.texts_represent_same_budget_item?(name, possible_item.name)
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

    def cumulative_spent_finance_amount
      totals_row.spent_finance
    end

    def cumulative_planned_finance_amount
      totals_row.planned_finance
    end

    def name
      Name.clean_text(header_row.name).gsub('–', '-')
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
