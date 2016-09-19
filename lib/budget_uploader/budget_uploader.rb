require 'rubyXL'
require_relative 'monthly_budget_sheet/monthly_budget_sheet'

class BudgetUploader

  def self.budget_files_dir
    Rails.root.join('budget_files', 'repo')
  end

  def initialize
    @start_time = Time.now
    @num_monthly_sheets_processed = 0
  end

  def upload_folder(folder)
    puts "\nBEGIN: Budget Uploader\n\n"
    puts "Uploading all budget data from files in #{folder} to database\n\n"

    begin
      upload_monthly_sheets(MonthlyBudgetSheet.file_paths(folder))
    rescue StandardError => error
      puts "\n\nStopping uploader due to ERROR: #{error}"
      puts error.backtrace
    end

    puts "\nEND: Budget Uploader"
    puts "Time elapsed: #{pretty_time(total_elapsed_time)}"
    puts "Number of monthly budget sheets processed: #{num_monthly_sheets_processed}"
    puts "Average time per monthly budget sheet: #{pretty_time(average_time_per_spreadsheet)}"
  end

  private

  def upload_monthly_sheets(monthly_sheet_paths)
    monthly_sheets = monthly_sheet_paths.map do |monthly_sheet_path|
      MonthlyBudgetSheet.new(monthly_sheet_path)
    end

    monthly_sheets_ordered = order_monthly_sheets_by_start_date(monthly_sheets)

    monthly_sheets_ordered.each do |monthly_sheet|
      ActiveRecord::Base.transaction do
        monthly_sheet.save_data
      end

      self.num_monthly_sheets_processed = num_monthly_sheets_processed + 1
    end
  end

  def order_monthly_sheets_by_start_date(sheets)
    sheets.sort do |sheet1, sheet2|
      sheet1.start_date <=> sheet2.start_date
    end
  end

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
