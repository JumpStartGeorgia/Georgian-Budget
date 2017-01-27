module Csv
  class PrimaryFinancesZipper
    attr_reader :zip_filepath, :locale

    def initialize(args)
      @zip_filepath = args[:zip_filepath]
      @locale = args[:locale]
    end

    def export
      require 'zip'
      
      Zip::File.open(zip_filepath, Zip::File::CREATE) do |zipfile|
        input_filepaths.each do |filepath|
          zipfile.add(File.basename(filepath), filepath)
        end
      end
    end

    def input_filepaths
      @input_filepaths ||= [
        Csv::PrimaryFinances.new(
          time_period_type: 'yearly',
          locale: locale
        ).export,
        Csv::PrimaryFinances.new(
          time_period_type: 'quarterly',
          locale: locale
        ).export,
        Csv::PrimaryFinances.new(
          time_period_type: 'monthly',
          locale: locale
        ).export
      ]
    end
  end
end
