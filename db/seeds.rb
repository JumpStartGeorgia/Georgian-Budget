=begin

This file should contain all the record creation needed to seed the database
with its default values. The data can then be loaded with the rake db:seed
(or created alongside the db with db:setup).

To seed database with default values:
rake db:seed

To view other data-related tasks:
rake -T budget_data

=end

puts 'Begin Seeding Database'

roles = %w(super_admin site_admin content_manager)
roles.each do |role|
  Role.find_or_create_by(name: role)
end

puts "\nEnd Seeding Database"
