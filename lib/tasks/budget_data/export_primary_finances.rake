namespace :budget_data do
  desc 'Export all primary finances of a specific time period type'
  task export_primary_finances: :environment do
    puts "exporting primary finances ka zip to system/csv"

    Csv::PrimaryFinancesZipper.new(
      zip_file_dir: Rails.root.join('public', 'system', 'csv'),
      locale: 'ka'
    ).export

    puts "exporting primary finances en zip to system/csv"

    Csv::PrimaryFinancesZipper.new(
      zip_file_dir: Rails.root.join('public', 'system', 'csv'),
      locale: 'en'
    ).export
  end
end
