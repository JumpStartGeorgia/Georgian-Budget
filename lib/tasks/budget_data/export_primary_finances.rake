namespace :budget_data do
  desc 'Export all primary finances of a specific time period type'
  task export_primary_finances: :environment do
    locale = 'ka'

    Csv::PrimaryFinancesZipper.new(
      zip_filepath: Rails.root.join('tmp', 'csv', "primary_finances_#{locale}.zip"),
      locale: locale
    ).export
  end
end
