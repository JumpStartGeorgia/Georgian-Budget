set :domain, 'alpha.jumpstart.ge'
set :user, 'budget-staging'
set :application, 'Budget-Staging'
# easier to use https; if you use ssh then you have to create key on server
set :repository, 'https://github.com/JumpStartGeorgia/Georgian-Budget'
set :branch, 'master'
set :web_url, ENV['STAGING_WEB_URL']
set :visible_to_robots, false
set :use_ssl, false
