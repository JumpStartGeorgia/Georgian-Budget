namespace :budget_data do
  desc 'Export CSVs of items that contain suspicious data'
  task :export_suspicious_items, [:directory_path] => :environment do |t, args|
    Csv::SuspiciousItems.new(args).export
  end
end
