namespace :budget_data do
  desc 'Export all primary finances of a specific time period type'
  task export_primary_finances: :environment do
    Csv::PrimaryFinancesZipper.new(
      zip_file_dir: Rails.root.join('public', 'system', 'csv'),
      locale: 'ka'
    ).export

    Csv::PrimaryFinancesZipper.new(
      zip_file_dir: Rails.root.join('public', 'system', 'csv'),
      locale: 'en'
    ).export
  end
end
