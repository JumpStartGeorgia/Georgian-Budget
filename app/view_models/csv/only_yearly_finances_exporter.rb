module Csv
  class OnlyYearlyFinancesExporter
    attr_reader :directory_path

    def initialize(options = {})
      @directory_path = options[:directory_path]
    end

    def export
      require 'fileutils'
      require 'csv'

      FileUtils.mkdir_p directory_path
      I18n.with_locale 'ka' do
        CSV.open(csv_file_path, 'wb') do |csv|
          rows.each { |row| csv << row }
        end
      end
    end

    private

    def rows
      [header_row].concat(item_rows)
    end

    def header_row
      [
        'perma_id',
        'name',
        'code'
      ]
    end

    def item_rows
      BudgetItem.klasses
      .map { |klass| item_rows_for_klass(klass) }
      .inject(:+)
    end

    def item_rows_for_klass(budget_item_klass)
      budget_item_klass.all.select do |item|
        item.spent_finances.yearly.present? &&
        item.spent_finances.count == item.spent_finances.yearly.count
      end.map do |item|
        [
          item.perma_id,
          item.name,
          item.code
        ]
      end
    end

    def csv_file_path
      directory_path.join(csv_file_name).to_s
    end

    def csv_file_name
      'only_yearly_finances.csv'
    end
  end
end
