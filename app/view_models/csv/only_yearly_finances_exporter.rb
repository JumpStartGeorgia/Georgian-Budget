module Csv
  class OnlyYearlyFinancesExporter
    attr_reader :directory_path

    def initialize(options = {})
      @directory_path = options[:directory_path]
    end

    def export
      puts "\nExporting CSV to #{csv_file_path}"

      require 'fileutils'
      require 'csv'

      FileUtils.mkdir_p directory_path
      I18n.with_locale 'ka' do
        CSV.open(csv_file_path, 'wb') do |csv|
          rows.each { |row| csv << row }
        end
      end

      puts "Finished exporting CSV to #{csv_file_path}"
    end

    private

    def rows
      [header_row].concat(item_rows)
    end

    def header_row
      [
        'perma_id',
        'type',
        'name',
        'code',
        'exists in spreadsheets',
        '# yearly spent',
        '# quarterly spent',
        '# monthly spent'
      ]
    end

    def item_rows
      BudgetItem.klasses
      .map { |klass| item_rows_for_klass(klass) }
      .inject(:+)
    end

    def item_rows_for_klass(budget_item_klass)
      budget_item_klass.all.select do |item|
        item.spent_finances.yearly.official.present? &&
        item.spent_finances.quarterly.official.empty? &&
        item.spent_finances.monthly.official.empty?
      end.map do |item|
        [
          item.perma_id,
          item.class.to_s,
          item.name,
          item.code,
          TimePeriods::SpreadsheetsContainingItem.call(item).map(&:to_s).join(','),
          item.spent_finances.yearly.official.count,
          item.spent_finances.quarterly.official.count,
          item.spent_finances.monthly.official.count
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
