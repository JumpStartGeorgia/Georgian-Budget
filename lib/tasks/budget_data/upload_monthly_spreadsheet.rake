require Rails.root.join('app', 'classes', 'monthly_budget_sheet', 'file')

namespace :budget_data do
  desc 'Upload one monthly spreadsheet; for testing purposes'
  task :upload_monthly_spreadsheet, [:monthly_sheet_path] => :environment do |t, args|
    MonthlyBudgetSheet::File
    .new_from_file(args[:monthly_sheet_path])
    .save_data
  end
end
