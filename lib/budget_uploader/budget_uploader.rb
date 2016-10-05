require 'rubyXL'
require_relative 'budget_item_english_translations'
require Rails.root.join(
  'lib',
  'budget_uploader',
  'budget_item_english_translations'
).to_s

class BudgetUploader
  def self.monthly_spreadsheet_dir
    budget_files_dir.join('monthly_spreadsheets')
  end

  def self.english_translations_file
    budget_files_dir.join('budget_item_english_translations.csv').to_s
  end

  def initialize
    @start_time = Time.now
    @num_monthly_sheets_processed = 0
  end

  def upload(args)
    monthly_folder = args[:monthly_folder]
    monthly_paths = args[:monthly_paths]
    budget_item_english_translations = args[:budget_item_english_translations]

    start_messages

    if monthly_folder.present?
      upload_monthly_folder(monthly_folder)
    elsif monthly_paths.present?
      upload_monthly_sheets(monthly_paths)
    end

    if budget_item_english_translations.present?
      BudgetItemEnglishTranslations.new(
        budget_item_english_translations
      ).save
    end

    end_messages
  end

  private

  def self.budget_files_dir
    Rails.root.join('budget_files', 'repo', 'files')
  end

  def upload_monthly_folder(folder)
    upload_monthly_sheets(MonthlyBudgetSheet::File.file_paths(folder))
  end

  def start_messages
    puts "\nBEGIN: Budget Uploader\n\n"
  end

  def end_messages
    puts "\nEND: Budget Uploader"
    puts "Time elapsed: #{pretty_time(total_elapsed_time)}"
    puts "Number of monthly budget sheets processed: #{num_monthly_sheets_processed}"
    puts "Average time per monthly budget sheet: #{pretty_time(average_time_per_spreadsheet)}"
  end

  def upload_monthly_sheets(monthly_sheet_paths)
    monthly_sheets = monthly_sheet_paths.map do |monthly_sheet_path|
      MonthlyBudgetSheet::File.new(monthly_sheet_path)
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
