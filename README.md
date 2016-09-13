# Georgian Budget

This web application visualizes the national budget of the Republic of Georgia.

## Get Started with Docker
1. Setup .env file
  1. `cp .env.example .env`
  2. Add Secrets (use `rake secret` to generate values)
  3. Use `postgres` as the value for `DB_USER` and `TEST_DB_USER`
  4. Set database names for `DB_NAME` and `TEST_DB_NAME`, such as starter_template_dev and starter_template_test
2. Install [docker](https://www.docker.com/products/overview)
3. `docker-compose build`
4. `docker-compose up`
5. `docker-compose run web rake db:create db:migrate`
6. `docker-compose run web rake db:seed` (See db/seeds.rb for more seeding options)

## Docker Cheat Sheet

This is a cheat sheet for JumpStart's Rails docker projects. If you want to truly understand what's going on here, consult the Docker documentation and work through their tutorials.

### Build (or rebuild) images

`docker-compose build`

### Start up project

`docker-compose up`

### Bundler

If you're missing a gem, you don't want to rebuild the docker web image — that takes too long, as it forces docker to install all the gems. Instead:

`docker-compose run web bundle install`

Or to update:

`docker-compose run web bundle update`

### Open bash session in web container

If you find yourself typing a lot of commands prefixed by `docker-compose run web`, you can open a bash session in the `web` container and just type them there.

```
docker-compose run web rake db:create
docker-compose run web rake db:migrate
docker-compose run web rake db:seed
docker-compose run web rspec
docker-compose run web rails g migration AddColumnDockerKnowledgeToBrain
```

Can be run like this:

```
docker-compose run web bash
# then, in bash
rake db:create
rake db:migrate
rake db:seed
rspec
rails g migration AddColumnDockerKnowledgeToBrain
# and when you're done
exit
```

### View status of docker-compose  services

`docker-compose ps`

### Attach to a docker-compose service container

If you want to view the output or interact with a running container, you can attach to it like below. (This is helpful if you use binding.pry to debug the server.)

```
docker-compose ps
# find the name of the container you want to attach to
# below we will attach to georgianbudget_web_1
docker attach georgianbudget_web_1
```

### Convenient Aliases

You'll be typing `docker` and `docker-compose` a lot, so I recommend creating bash aliases for these commands. For example, you can add the following lines to your ~/.bash_profile (or ~/.bashrc):

```
alias do='docker'
alias doco='docker-compose'
```

Then, you can substitute `doco` for `docker-compose` and `do` for `docker` in all of these commands.
