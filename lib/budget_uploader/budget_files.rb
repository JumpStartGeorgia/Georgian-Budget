require 'rubyXL'
require_relative 'budget_item_translations'

require_relative 'priorities_list'
require_relative 'priority_associations/list'
require_relative 'priority_associations/row'

class BudgetFiles
  def self.monthly_spreadsheet_dir
    budget_files_dir.join('monthly_spreadsheets')
  end

  def self.english_translations_file
    budget_files_dir.join('budget_item_translations.csv').to_s
  end

  def self.priorities_list
    budget_files_dir.join('priorities_list.csv').to_s
  end

  def self.priority_associations_list
    budget_files_dir.join('priority_associations.csv').to_s
  end

  def initialize(args)
    @start_time = Time.now
    @num_monthly_sheets_processed = 0
    @budget_item_translations = get_budget_item_translations(args)
    @monthly_sheets = get_monthly_sheets(args)
    @priorities_list = get_priorities_list(args)
    @priority_associations_list = get_priority_associations_list(args)
  end

  def upload
    start_messages

    upload_monthly_sheets if monthly_sheets.present?
    budget_item_translations.save if budget_item_translations.present?
    priorities_list.save if priorities_list.present?
    priority_associations_list.save if priority_associations_list.present?

    end_messages
  end

  def self.budget_files_dir
    budget_files_repo_dir.join('files')
  end

  def self.budget_files_repo_dir
    Rails.root.join('budget_files', 'repo')
  end

  attr_accessor :num_monthly_sheets_processed

  attr_reader :monthly_sheets,
              :budget_item_translations,
              :priorities_list,
              :priority_associations_list,
              :start_time

  private

  def get_priority_associations_list(args)
    PriorityAssociations::List.new_from_file(
      args[:priority_associations_list],
      priorities_list: priorities_list
    )
  end

  def get_priorities_list(args)
    PrioritiesList.new_from_file(args[:priorities_list])
  end

  def get_monthly_sheets(args)
    if args[:monthly_paths]
      monthly_sheet_paths = args[:monthly_paths]
    elsif args[:monthly_folder]
      monthly_sheet_paths = MonthlyBudgetSheet::File.file_paths(args[:monthly_folder])
    end

    return nil unless monthly_sheet_paths.present?

    @monthly_sheets = monthly_sheet_paths.map do |monthly_sheet_path|
      MonthlyBudgetSheet::File.new(monthly_sheet_path)
    end.sort do |sheet1, sheet2|
      sheet1.start_date <=> sheet2.start_date
    end
  end

  def get_budget_item_translations(args)
    return nil unless args[:budget_item_translations]

    BudgetItemTranslations.new(
      args[:budget_item_translations]
    )
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

  def upload_monthly_sheets
    monthly_sheets.each do |monthly_sheet|
      ActiveRecord::Base.transaction do
        monthly_sheet.save_data
      end

      self.num_monthly_sheets_processed = num_monthly_sheets_processed + 1
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
end
