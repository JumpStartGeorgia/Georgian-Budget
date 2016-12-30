set :domain, 'delta.jumpstart.ge'
set :user, 'budget'
set :application, 'Budget-API-Production'
# easier to use https; if you use ssh then you have to create key on server
set :repository, 'https://github.com/JumpStartGeorgia/Georgian-Budget'
set :branch, 'master'
set :web_url, ENV['PRODUCTION_WEB_URL']
set :use_ssl, false
