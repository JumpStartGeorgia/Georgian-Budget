module Csv
  class PrimaryFinancesZipper
    attr_reader :zip_file_dir, :locale

    def initialize(args)
      @zip_file_dir = args[:zip_file_dir]
      @locale = args[:locale]
    end

    def export
      create_zip_filepath_dir
      create_zip_file
    end

    private

    def create_zip_filepath_dir
      require 'fileutils'

      FileUtils.mkdir_p(File.dirname(zip_filepath))
    end

    def zip_filepath
      zip_file_dir.join(zip_file_name).to_s
    end

    def zip_file_name
      "primary_finances_#{locale}.zip"
    end

    def create_zip_file
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
