namespace :budget_data do
  desc 'Exports priority connections'
  task export_priority_connections: :environment do
    Csv::PriorityConnections.new(locale: 'en').export
  end
end
