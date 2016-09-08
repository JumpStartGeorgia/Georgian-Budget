require_relative '../budget_uploader/budget_uploader'

namespace :budget_data do
  namespace :upload do
    desc 'Upload all spreadsheets in tmp/budget_files'
    task from_tmp_dir: :environment do
      uploader = BudgetUploader.new
      uploader.upload_folder(Rails.root.join('tmp', 'budget_files'))
    end
  end
end
