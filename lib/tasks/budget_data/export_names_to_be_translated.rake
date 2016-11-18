namespace :budget_data do
  desc 'Get list of unique budget item names to be translated'
  task get_georgian_names_to_be_translated: :environment do
    # inefficient, but there aren't enough names for it to matter
    names = Name.all.select { |name| name.text_en == nil }

    if names.count == 0
      puts 'All names translated!'
    else
      puts "There are #{names.count} names left to translate into English"
    end

    CSV.open(Rails.root.join('tmp', 'georgian_budget_names_to_be_translated.csv'), 'wb') do |csv|
      csv << ["Budget Item Code", "Georgian Name", "Budget Item Type", "English Translation"]
      names.each do |name|
        csv << [name.nameable.code, name.text_ka, name.nameable_type, name.text_en]
      end
    end
  end
end
