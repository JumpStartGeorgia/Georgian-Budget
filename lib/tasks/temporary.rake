require('csv')

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
    name_ids_without_english = Name.find_by_sql(
      <<-STRING
        SELECT names.id
        FROM names LEFT JOIN
          (SELECT * FROM name_translations
           WHERE name_translations.locale = 'en') AS name_translations
        ON names.id = name_translations.name_id
        WHERE name_translations.name_id IS NULL
      STRING
    ).pluck(:id)

    names = Name.find(name_ids_without_english)

    CSV.open(Rails.root.join('tmp', 'georgian_budget_names_to_be_translated.csv'), 'wb') do |csv|
      csv << ["Budget Item Code", "Georgian Name", "Budget Item Type", "English Translation"]
      names.each do |name|
        csv << [name.nameable.code, name.text_ka, name.nameable_type, name.text_en]
      end
    end
  end
end
