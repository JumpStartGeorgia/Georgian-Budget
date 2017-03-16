module TimePeriods
  class SpreadsheetsContainingItem
    def self.call(budget_item)
      spreadsheet_time_periods(budget_item).sort_by(&:start_date).uniq
    end

    private

    def self.spreadsheet_time_periods(budget_item)
      month_time_periods(budget_item) + year_time_periods(budget_item)
    end

    def self.month_time_periods(budget_item)
      month_time_periods_from_spent(budget_item) +
      month_time_periods_from_plans(budget_item)
    end

    def self.month_time_periods_from_spent(budget_item)
      budget_item.all_spent_finances.monthly.official.map(&:time_period_obj)
    end

    def self.month_time_periods_from_plans(budget_item)
      budget_item.all_planned_finances.quarterly.official.map do |finance|
        Month.for_date(finance.announce_date)
      end
    end

    def self.year_time_periods(budget_item)
      year_time_periods_from_spent(budget_item) +
      year_time_periods_from_plans(budget_item)
    end

    def self.year_time_periods_from_spent(budget_item)
      budget_item.all_spent_finances.yearly.official.map do |finance|
        finance.time_period_obj.next.next
      end
    end

    def self.year_time_periods_from_plans(budget_item)
      budget_item.all_planned_finances.yearly.official.map do |finance|
        Year.for_date(finance.announce_date)
      end
    end
  end
end
