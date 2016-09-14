require_relative '../budget_uploader/budget_uploader'

namespace :budget_data do
  namespace :upload do
    desc 'Upload all spreadsheets in tmp/budget_files'
    task from_tmp_dir: :environment do
      uploader = BudgetUploader.new
      uploader.upload_folder(BudgetUploader.budget_files_dir)
    end

    desc 'Upload one monthly spreadsheet'
    task :monthly_sheet, [:path] do |t, args|
      monthly_sheet = MonthlyBudgetSheet.new(args[:path])
      monthly_sheet.save_data
    end
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
