namespace :db do
  desc 'Create users for testing the app. Not allowed on production'
  task create_test_users: :environment do
    if Rails.env.production?
      throw 'Creating test users not allowed on production'
    end

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

  desc 'Destroy all data that are not users or roles. Not allowed on production'
  task destroy_non_user_data: :environment do
    if Rails.env.production?
      throw 'Creating test users not allowed on production'
    end

    puts "\nDestroying Programs\n"
    Program.destroy_all

    puts "\nDestroying Priorities\n"
    Priority.destroy_all

    puts "\nDestroying Spending Agencies\n"
    SpendingAgency.destroy_all

    puts "\nDestroying Names\n"
    Name.destroy_all
  end
end
