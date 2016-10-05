require_relative '../budget_uploader/budget_files'

namespace :budget_data do
  desc 'Upload all spreadsheets in budget_files directory'
  task upload: :environment do
    BudgetFiles.new(
      monthly_folder: BudgetFiles.monthly_spreadsheet_dir,
      budget_item_english_translations: BudgetFiles.english_translations_file
    ).upload
  end

  desc 'Download all files from JumpStartGeorgia/Georgian-Budget-Files repo to tmp/budget_files'
  task :sync_with_repo do
    require 'fileutils'

    FileUtils::mkdir_p BudgetFiles.budget_files_dir
    FileUtils.cd(BudgetFiles.budget_files_dir)

    if File.directory?(BudgetFiles.budget_files_dir.join('.git'))
      puts 'Budget files repo already exists; pulling in changes'
      `git pull`
    else
      `git clone https://github.com/JumpStartGeorgia/Georgian-Budget-Files.git .`
    end
  end
end
