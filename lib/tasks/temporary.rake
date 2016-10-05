require('csv')
require('pry-byebug')

namespace :temporary do
  desc 'Get names from the database that have multiple codes'
  task find_names_with_multiple_codes: :environment do
    names = Name.find_by_sql('SELECT MAX(names.id) AS id FROM names JOIN name_translations ON names.id = name_translations.id GROUP BY nameable_type, nameable_id, name_translations.text HAVING count(name_translations.text) > 1')

    csv_name = 'georgian_budget_names_with_different_codes.csv'

    CSV.open(Rails.root.join('tmp', csv_name), 'wb') do |csv|
      csv << ['Georgian Name', 'Codes', 'Number of different codes']

      names.each do |name|
        name_text = Name.find(name.id).text
        codes = []

        [Program, SpendingAgency, Priority, Total].each do |budgetClass|
          codes += budgetClass.find_by_name(name_text).map(&:code)
        end

        codes = codes.uniq

        csv << [name_text, codes.join(', '), codes.count]
      end
    end
  end

  desc 'Get list of unique budget item names to be translated'
  task get_georgian_names_to_be_translated: :environment do
    names = Name.find_by_sql('SELECT MAX(names.id) AS id, MAX(name_translations.text) AS text_ka, MAX(nameable_id) AS nameable_id, MAX(names.nameable_type) AS nameable_type FROM names JOIN name_translations ON names.id = name_translations.id GROUP BY name_translations.text')

    CSV.open(Rails.root.join('tmp', 'georgian_budget_names_to_be_translated.csv'), 'wb') do |csv|
      csv << ["Budget Item Code", "Georgian Name", "Budget Item Type", "English Translation"]
      names.each do |name|
        csv << [Name.find(name.id).nameable.code, Name.find(name.id).text, name.nameable_type]
      end
    end
  end

  desc 'Change codes that are 0 in spreadsheet to 00'
  task fix_spreadsheet_codes: :environment do
    budget_files = BudgetFiles.new(monthly_folder: BudgetFiles.monthly_spreadsheet_dir)

    budget_files.monthly_sheets.each do |monthly_sheet|
      month = Month.for_date(Date.new(monthly_sheet.year, monthly_sheet.month, 1))
      puts "\nProcessing #{month.to_s} spreadsheet"

      rows_changed = 0

      monthly_sheet.data_rows.each do |row_data|
        row = MonthlyBudgetSheet::Row.new(row_data)

        next unless row.code == '0'

        row.code_cell.change_contents('00')
        rows_changed += 1
      end

      puts "#{rows_changed} code cells found with value of 0"

      if rows_changed > 0
        monthly_sheet.excel_data.write(monthly_sheet.spreadsheet_path)
        puts 'Writing fixed data to spreadsheet'
      end
    end
  end
end
