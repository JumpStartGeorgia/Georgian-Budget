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
  task export_possible_duplicate_budget_items: :environment do
    csv_file_path = Rails.root.join('tmp', 'possible_duplicate_budget_items.csv')

    headers = [
      'Budget Item Type',
      'Budget Item 1 Code',
      'Budget Item 2 Code',
      'Budget Item 1 Name',
      'Budget Item 2 Name',
      'Budget Item 1 Name Date',
      'Budget Item 2 Name Date',
      'Merge? (yes / no)'
    ]

    require 'csv'
    CSV.open(csv_file_path, 'wb') do |csv|
      csv << headers

      PossibleDuplicatePair
      .all
      .order(pair_type: :desc)
      .each do |possible_duplicate_pair|
        item1 = possible_duplicate_pair.item1
        item2 = possible_duplicate_pair.item2

        csv << [
          possible_duplicate_pair.pair_type,
          item1.code,
          item2.code,
          item1.name_ka,
          item2.name_ka,
          item1.recent_name_object.start_date,
          item2.recent_name_object.start_date,
          ''
        ]
      end
    end
  end

  desc 'Get list of unique budget item names to be translated'
  task get_georgian_names_to_be_translated: :environment do
    ids_sql = <<-STRING
      SELECT * FROM names
      WHERE NAMES.id IN (
        SELECT DISTINCT ON (georgian_translations.text)
               names.id AS id
        FROM names LEFT JOIN
          (SELECT * FROM name_translations
           WHERE name_translations.locale = 'en') AS english_translations
        ON names.id = english_translations.name_id
        JOIN
          (SELECT * FROM name_translations
           WHERE name_translations.locale = 'ka') AS georgian_translations
        ON names.id = georgian_translations.name_id
        WHERE english_translations.name_id IS NULL
        ORDER BY georgian_translations.text
      )
      ORDER BY CASE WHEN names.nameable_type = 'Priority' THEN '1'
                    WHEN names.nameable_type = 'SpendingAgency' THEN '2'
                    ELSE names.nameable_type END ASC
    STRING

    names = Name.find_by_sql(ids_sql)

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
