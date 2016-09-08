require 'rubyXL'
require_relative 'monthly_budget_sheet'

class BudgetUploader

  def initialize
  end

  def upload_folder(folder)
    puts "Uploading all budget data from files in #{folder} to database"

    monthly_sheet_paths = Dir.glob(Pathname.new(folder).join('ShesBiu-*.xlsx'))
    monthly_sheet_paths.each do |monthly_sheet_path|
      monthly_sheet = MonthlyBudgetSheet.new(monthly_sheet_path)
      monthly_sheet.save_data
    end
  end

end
