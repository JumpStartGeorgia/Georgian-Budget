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

    MonthlyBudgetSheet.file_paths(folder).each do |monthly_sheet_path|
      monthly_sheet = MonthlyBudgetSheet.new(monthly_sheet_path)
      monthly_sheet.save_data

      self.num_monthly_sheets_processed = num_monthly_sheets_processed + 1
    end

    puts "\nEND: Budget Uploader"
    puts "Time elapsed: #{pretty_time(total_elapsed_time)}"
    puts "Number of monthly budget sheets processed: #{num_monthly_sheets_processed}"
    puts "Average time per monthly budget sheet: #{pretty_time(average_time_per_spreadsheet)}"
  end

  private

  def pretty_time(time = 0)
    Time.at(time).utc.strftime("%H:%M:%S").to_s
  end

  def elapsed_since_start
    Time.at(total_elapsed_time).utc.strftime("%H:%M:%S").to_s
  end

  def average_time_per_spreadsheet
    return 0 if num_monthly_sheets_processed == 0
    total_elapsed_time/num_monthly_sheets_processed
  end

  def total_elapsed_time
    Time.now - start_time
  end

  attr_reader :start_time
  attr_accessor :num_monthly_sheets_processed
end
