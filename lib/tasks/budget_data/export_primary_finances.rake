namespace :budget_data do
  desc 'Export all primary finances of a specific time period type'
  task export_primary_finances: :environment do
    require 'zip'

    zipfile_path = Rails.root.join('tmp', 'csv', 'primary_finances.zip')
    locale = 'ka'

    input_filepaths = [
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

    Zip::File.open(zipfile_path, Zip::File::CREATE) do |zipfile|
      input_filepaths.each do |filepath|
        zipfile.add(File.basename(filepath), filepath)
      end
    end
  end
end
