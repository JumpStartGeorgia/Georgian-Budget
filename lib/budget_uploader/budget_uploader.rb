require 'rubyXL'
require_relative 'monthly_budget_sheet/monthly_budget_sheet'

class BudgetUploader

  def initialize
    @start_time = Time.now
    @num_monthly_sheets_processed = 0
  end

  def upload_folder(folder)
    puts "\nBEGIN: Budget Uploader\n\n"
    puts "Uploading all budget data from files in #{folder} to database\n\n"

    monthly_sheet_paths = Dir.glob(Pathname.new(folder).join('ShesBiu-*.xlsx'))
    monthly_sheet_paths.each do |monthly_sheet_path|
      monthly_sheet = MonthlyBudgetSheet.new(monthly_sheet_path)
      monthly_sheet.save_data

      self.num_monthly_sheets_processed = num_monthly_sheets_processed + 1
    end

    puts "\nEND: Budget Uploader"
    puts "Time elapsed: #{elapsed_since_start}"
    puts "Number of monthly budget sheets processed: #{num_monthly_sheets_processed}"
    puts "Average time per monthly budget sheet: #{average_time_per_spreadsheet}"
  end

  private

  def elapsed_since_start
    Time.at(total_elapsed_time).utc.strftime("%H:%M:%S").to_s
  end

  def average_time_per_spreadsheet
    Time.at(total_elapsed_time/num_monthly_sheets_processed).utc.strftime("%H:%M:%S").to_s
  end

  def total_elapsed_time
    Time.now - start_time
  end

  attr_reader :start_time
  attr_accessor :num_monthly_sheets_processed
end
