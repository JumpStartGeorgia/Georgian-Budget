require 'rubyXL'
require_relative 'monthly_budget_sheet/monthly_budget_sheet'

class BudgetUploader

  def initialize
    @start_time = Time.now
  end

  def upload_folder(folder)

    puts "\nBEGIN: Budget Uploader\n\n"
    puts "Uploading all budget data from files in #{folder} to database"

    monthly_sheet_paths = Dir.glob(Pathname.new(folder).join('ShesBiu-*.xlsx'))
    monthly_sheet_paths.each do |monthly_sheet_path|
      monthly_sheet = MonthlyBudgetSheet.new(monthly_sheet_path)
      monthly_sheet.save_data
    end

    puts "\nEND: Budget Uploader"
    puts "Time elapsed: #{elapsed_since_start.to_s}"
  end

  def elapsed_since_start
    Time.at(Time.now - start_time).utc.strftime("%H:%M:%S")
  end

  attr_reader :start_time
end
