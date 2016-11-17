namespace :budget_data do
  namespace :test_data do
    desc 'Create users for testing the app; not allowed on production'
    task create_test_users: :environment do
      stop_if_production

      test_user_password = 'password123'

      test_users = [
        {
          email: 'super.admin@test.ge',
          password: test_user_password,
          role: 'super_admin'
        },
        {
          email: 'site.admin@test.ge',
          password: test_user_password,
          role: 'site_admin'
        },
        {
          email: 'content.manager@test.ge',
          password: test_user_password,
          role: 'content_manager'
        }
      ]

      puts "\nCREATING USERS\n"

      test_users.each do |test_user_data|
        old_test_user = User.find_by_email(test_user_data[:email])
        old_test_user.destroy if old_test_user.present?

        puts "\nCreating (#{test_user_data[:role]})\nEmail: #{test_user_data[:email]}\nPassword: #{test_user_data[:password]}\n"

        User.create(
          email: test_user_data[:email],
          password: test_user_data[:password],
          role: Role.find_by_name(test_user_data[:role])
        )
      end
    end
  end

  desc 'Destroy all data that are not users or roles; not allowed on production'
  task destroy_non_user_data: :environment do
    stop_if_production

    puts "\nDestroying Spent Finances"
    SpentFinance.destroy_all

    puts "\nDestroying Planned Finances"
    PlannedFinance.destroy_all

    puts "\nDestroying Names"
    Name.destroy_all

    puts "\nDestroying Programs"
    Program.destroy_all

    puts "\nDestroying Spending Agencies"
    SpendingAgency.destroy_all

    puts "\nDestroying Priorities"
    Priority.destroy_all

    puts "\nDestroying Totals"
    Total.destroy_all
  end

  desc 'Export CSV of possible duplicate budget items'
  task :export_possible_duplicate_budget_items, [:locale] => :environment do |t, args|
    I18n.locale = args[:locale]

    file_name = "possible_duplicate_budget_items_#{I18n.locale}.csv"
    csv_file_path = Rails.root.join('tmp', file_name)

    possible_duplicate_pairs = PossibleDuplicatePair
    .all
    .order(pair_type: :desc)

    require 'csv'
    CSV.open(csv_file_path, 'wb') do |csv|
      csv << [
        'Budget Item Type',
        'Budget Item 1 Code',
        'Budget Item 2 Code',
        'Budget Item 1 Name',
        'Budget Item 2 Name',
        'Budget Item 1 Dates',
        'Budget Item 2 Dates',
        'Marked on Date',
        'Priority Names (if different)',
        'Merge? (yes / no)'
      ]

      possible_duplicate_pairs.each do |possible_duplicate_pair|
        item1 = possible_duplicate_pair.item1
        item2 = possible_duplicate_pair.item2

        csv << [
          possible_duplicate_pair.pair_type,
          possible_duplicate_pair.item1_code_when_found,
          possible_duplicate_pair.item2_code_when_found,
          possible_duplicate_pair.item1_name_when_found,
          possible_duplicate_pair.item2_name_when_found,
          "#{item1.start_date} - #{item1.end_date}",
          "#{item2.start_date} - #{item2.end_date}",
          possible_duplicate_pair.date_when_found,
          possible_duplicate_pair.priorities_differ? ? "Item 1 priority: #{item1.priority.name} |||||| Item 2 priority: #{item2.priority.name}" : '',
          ''
        ]
      end
    end

    puts "Finished exporting CSV of possible duplicate pairs"
    puts "File path: #{csv_file_path}"
    puts "Number of Possible Duplicate Pairs: #{possible_duplicate_pairs.count}"
  end

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

def stop_if_production
  if Rails.env.production?
    throw 'This task is not allowed on production'
  end
end
