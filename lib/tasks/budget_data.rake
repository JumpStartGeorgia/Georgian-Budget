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

    desc 'Create test data; not allowed on production'
    task create_test_data: :environment do
      stop_if_production

      puts "\nCREATING PROGRAMS\n"

      program1 = Program.create
      Name.create(
        text: 'Program #1',
        start_date: Date.yesterday,
        end_date: Date.today,
        nameable: program1
      )

      program2 = Program.create
      Name.create(
        text: 'Program #2',
        start_date: Date.yesterday,
        end_date: Date.today,
        nameable: program2
      )

      puts "\nCREATING PRIORITIES\n"

      priority1 = Priority.create
      Name.create(
        text: 'Priority #1',
        start_date: Date.yesterday,
        end_date: Date.today,
        nameable: priority1
      )

      priority2 = Priority.create
      Name.create(
        text: 'Priority #2',
        start_date: Date.yesterday,
        end_date: Date.today,
        nameable: priority2
      )

      puts "\nCREATING SPENDING AGENCIES\n"

      spending_agency1 = SpendingAgency.create
      Name.create(
        text: 'Spending Agency #1',
        start_date: Date.yesterday,
        end_date: Date.today,
        nameable: spending_agency1
      )

      spending_agency2 = SpendingAgency.create
      Name.create(
        text: 'Spending Agency #2',
        start_date: Date.yesterday,
        end_date: Date.today,
        nameable: spending_agency2
      )
    end
  end

  desc 'Destroy all data that are not users or roles; not allowed on production'
  task destroy_non_user_data: :environment do
    stop_if_production

    puts "\nDestroying Programs\n"
    Program.destroy_all

    puts "\nDestroying Priorities\n"
    Priority.destroy_all

    puts "\nDestroying Spending Agencies\n"
    SpendingAgency.destroy_all

    puts "\nDestroying Names\n"
    Name.destroy_all

    puts "\nDestroying Spent Finances\n"
    SpentFinance.destroy_all
  end
end

def stop_if_production
  if Rails.env.production?
    throw 'This task is not allowed on production'
  end
end
