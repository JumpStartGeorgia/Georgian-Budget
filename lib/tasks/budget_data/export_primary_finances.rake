namespace :budget_data do
  desc 'Export all primary finances of a specific time period type'
  task export_primary_finances: :environment do
    PrimaryFinancesCSVExporter.new('yearly', 'ka').export
  end
end
