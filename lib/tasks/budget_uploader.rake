require_relative '../budget_uploader/budget_uploader'

namespace :budget_uploader do
  desc 'Upload all spreadsheets in tmp/budget_files'
  task upload_files: :environment do
    uploader = BudgetUploader.new
    uploader.upload_folder(Rails.root.join('tmp', 'budget_files'))
  end
end
