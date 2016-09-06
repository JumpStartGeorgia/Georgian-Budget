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
