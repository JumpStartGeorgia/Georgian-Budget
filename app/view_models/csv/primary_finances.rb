# NOT TESTED

module Csv
  class PrimaryFinances
    attr_reader :time_period_type, :locale

    def initialize(args)
      @time_period_type = args[:time_period_type]
      @locale = args[:locale]

      unless possible_time_period_types.include?(time_period_type)
        raise "Unallowed time period type: #{time_period_type}. Possible time period types are: #{possible_time_period_types.join(', ')}"
      end
    end

    def export
      require 'fileutils'
      FileUtils.mkdir_p(csv_dir)

      require 'csv'
      I18n.with_locale locale do
        CSV.open(csv_file_path, 'wb') do |csv|
          rows.each { |row| csv << row }
        end
      end

      return csv_file_path
    end

    private

    def possible_time_period_types
      ['monthly', 'quarterly', 'yearly']
    end

    def rows
      [headers] + content_rows
    end

    def csv_file_path
      csv_dir.join(file_name)
    end

    def csv_dir
      Rails.root.join('tmp', 'csv')
    end

    def file_name
      "complete_primary_finances_#{time_period_type}_#{locale}.csv"
    end

    def headers
      [
        'Type',
        'Name',
        'Code',
        'Finance Type'
        ] + time_period_headers
      end

      def time_period_headers
        uniq_time_period_strings
      end

      def content_rows
        budget_item_types
        .map { |type_klass| rows_for_budget_item_type(type_klass) }
        .sum
      end

      def budget_item_types
        [
          Total,
          Priority,
          SpendingAgency,
          Program
        ]
      end

      def rows_for_budget_item_type(type_klass)
        type_klass.all.map do |item|
          rows_for(item)
        end.sum
      end

      def rows_for(item)
        rows = [values_for_item_finance_type(item, SpentFinance)]
        return rows if time_period_type == 'monthly'
        return rows << values_for_item_finance_type(item, PlannedFinance)
      end

      def values_for_item_finance_type(item, finance_klass)
        basic_values_for_item_finance_type(item, finance_klass) +
        finances_for(item, finance_klass)
      end

      def basic_values_for_item_finance_type(item, finance_klass)
        [
          item.class.to_s,
          item.name,
          item.respond_to?(:code) ? item.code : 'N/A',
          finance_klass.to_s
        ]
      end

      def finances_for(item, finance_klass)
        uniq_time_period_strings.map do |time_period_string|
          amount_for_item_in_time_period(item, finance_klass, time_period_string)
        end
      end

      def amount_for_item_in_time_period(item, finance_klass, time_period_string)
        finance = item_finances_for_klass(item, finance_klass)
        .find { |f| f.time_period == time_period_string }

        finance.present? ? finance.amount : ''
      end

      def item_finances_for_klass(item, finance_klass)
        if finance_klass == SpentFinance
          return item.spent_finances
        elsif finance_klass == PlannedFinance
          return item.planned_finances
        end
      end

      def uniq_time_period_strings
        @uniq_time_period_strings ||= all_time_period_strings.uniq
      end

      def all_time_period_strings
        distinct_time_periods_for_finance(SpentFinance) +
        distinct_time_periods_for_finance(PlannedFinance)
      end

      def distinct_time_periods_for_finance(finance_class)
        finance_class
        .select(:time_period, :start_date)
        .send(time_period_type)
        .order(:start_date)
        .group(:time_period, :start_date)
        .pluck(:time_period)
      end
    end
end
