require_relative '../budget_uploader/budget_uploader'

namespace :budget_data do
  desc 'Upload all spreadsheets in budget_files directory'
  task upload: :environment do
    uploader = BudgetUploader.new
    uploader.upload_folder(BudgetUploader.budget_files_dir)
  end

  desc 'Download all files from JumpStartGeorgia/Georgian-Budget-Files repo to tmp/budget_files'
  task :sync_with_repo do
    require 'fileutils'

    FileUtils::mkdir_p BudgetUploader.budget_files_dir
    FileUtils.cd(BudgetUploader.budget_files_dir)

    if File.directory?(BudgetUploader.budget_files_dir.join('.git'))
      puts 'Budget files repo already exists; pulling in changes'
      `git pull`
    else
      `git clone https://github.com/JumpStartGeorgia/Georgian-Budget-Files.git .`
    end
  end
end
