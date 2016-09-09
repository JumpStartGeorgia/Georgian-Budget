require_relative '../budget_uploader/budget_uploader'

namespace :budget_data do
  namespace :upload do
    desc 'Upload all spreadsheets in tmp/budget_files'
    task from_tmp_dir: :environment do
      uploader = BudgetUploader.new
      uploader.upload_folder(Rails.root.join('tmp', 'budget_files'))
    end

    desc 'Upload one monthly spreadsheet'
    task :monthly_sheet, [:path] do |t, args|
      monthly_sheet = MonthlyBudgetSheet.new(args[:path])
      monthly_sheet.save_data
    end
  end
end
