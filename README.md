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

## Deploy from within web container
The web container is not configured by default to work for deploying, so you will have to do a little bit of configuration in order to do so. This section is intended to make that configuration easier.

Ideally, this is only a temporary solution until we figure out how to deploy with docker.

NOTE: The below commands will only work if the container you are setting up to deploy from is named `georgianbudget_web_1`. If it has a different name, then use it below in the `docker cp` commands.

1. Copy your global gitignore into the `web` container:
  ```
  COPY ~/.gitignore_global georgianbudget_web_1:/root/
  ```

2. Run these commands from within the `web` container:
  ```
  git config --global core.excludesfile /root/.gitignore_global

  bundle_path=$(which bundle)
  sed -i -e "s/activate_bin_path/bin_path/g" $bundle_path

  mkdir -p /root/.ssh

  apt-get -y install rsync
  ```

  In order: configure git to use .gitignore_global; fix bundle issue described [here](https://github.com/bundler/bundler/issues/4602#issuecomment-233619696); create .ssh directory if it doesn't exist; install rsync, which is a dependency of the deploy process.

3. Make sure your local user has an ssh key at ~/.ssh/id_rsa and ~/.ssh/id_rsa.pub.
  ```
  docker cp ~/.ssh/id_rsa georgianbudget_web_1:/root/.ssh/
  docker cp ~/.ssh/id_rsa.pub georgianbudget_web_1:/root/.ssh/
  ```

4. Add your ssh key to the container's ssh-agent so that it doesn't ask for your passphrase when you deploy. You will have to enter your ssh key's passphrase.

  ```
  eval "$(ssh-agent -s)"
  ssh-add ~/.ssh/id_rsa
  ```

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
