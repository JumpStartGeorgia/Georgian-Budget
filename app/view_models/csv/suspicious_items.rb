module Csv
  class SuspiciousItems
    attr_reader :directory_path

    def initialize(options)
      @directory_path = options[:directory_path] ||= default_directory_path
    end

    def export
      Csv::OnlyYearlyFinancesExporter
      .new(directory_path: directory_path)
      .export
    end

    private

    def default_directory_path
      Rails.root.join('tmp', 'suspicious_items')
    end
  end
end
