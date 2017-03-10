module Csv
  class SuspiciousItems
    attr_reader :directory_path

    def initialize(options)
      @directory_path = options[:directory_path] ||= default_directory_path
    end

    def export
      puts "\nExporting suspicious items to directory #{directory_path}"

      Csv::OnlyYearlyFinancesExporter
      .new(directory_path: directory_path)
      .export

      Csv::OnlyMonthlyOrQuarterlyFinancesExporter
      .new(directory_path: directory_path)
      .export

      Csv::NoPriorityConnectionsExporter
      .new(directory_path: directory_path)
      .export

      puts "\nFinished exporting suspicious items to directory #{directory_path}"
    end

    private

    def default_directory_path
      Rails.root.join('tmp', 'suspicious_items')
    end
  end
end
