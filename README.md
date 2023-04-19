# Rails On Docker

## Overview

This is a collection of Docker Compose files to make Rails development easier.

These files can be combined to add services such as databases
and memory caches to your development environment.

## Available Configurations

### Docker

There are two Dockerfiles `Dockerfile` and `Dockerfile-Node`. The latter adds
Node and Yarn to the configurations, like webpack, that need them.

### Docker Compose Files

#### Databases

- PostgreSQ - docker-compose-postgres.yml
- MySQL - docker-compose-mysql.yml
- MongoDB - docker-compose-mongo.yml

#### Memory Stores and Queues

- Redis - docker-compose-redis.yml
- Memcached - docker-compose-memcached.yml
- Sidkiq - docker-compose-sidekiq.yml - Requires docker-compose-redis.yml

#### Development

- ngrok - docker-compose-ngrok.yml - Configure ngrok to access your app with
  DNS and SSL. Creates an SSL to your development environment. Requires
  two variables to be set in the _.env_ file. NGROK*SUBDOMAIN
  sets the first part of the tunnel's URL, `NGROK_SUBDOMAIN=example` will set
  the URL to https://example.ngrok.io. The value of
  NGROK_AUTH is the value \_authtoken* in ~/.ngrok2/ngrok.yml.
- Webpack - docker-compose-webpack.yml - Requires _Dockerfile-Node_
- Tailwind - docker-compose-tailwindcss.yml - Watches and complies Tailwindcss files.

## Adding to an Existing Project

Copy _Dockerfile_ and _docker-compose.yml_ to your Rails project along with the
Compose files for any services you need. For example, if you will be using
PostgreSQL, copy _docker-compose-postgres.yml_.

```
cp Dockerfile docker-compose.yml docker-compose-postgres.yml /path/to/my/project
```

`cd` to your project directory and create (or edit) file called _.env_, and add a
line which reads:

```
COMPOSE_FILE=docker-compose.yml:docker-compose-postgres.yml
```

Then edit _Dockerfile_ and change the line that reads:

```
FROM ruby
```

to

```
FROM ruby:X.Y.Z
```

Where _X.Y.Z_ matches the Ruby version in your _Gemfile_ e.g. "3.2.2".

Then run:

```
docker-compose build
```

## Creating a New Rails App

Using these configurations, it's possible to create a new Rail app without
having Ruby or any dependencies installed locally.

Create a new directory and copy _Dockerfile_, _docker-compose.yml_, and
Compose files for any services you need. Copy _Gemfile.bootstrap_ into _Gemfile_.

```
cp Dockerfile docker-compose.yml docker-compose-postgres.yml /path/to/my/new/project
cp Gemfile.bootstrap /path/to/my/new/project/Gemfile
```

`cd` to the new directory and run:

```
docker-compose build
docker-compose run --rm app bundle exec rails new . --force --database=postgresql
```

You can pass any other options you need to the new command and swap out the
database type (swapping to matching Compose file as well). Be sure to leave the
`--force` as that allows Rails to replace the bootstrap Gemfile with a real one.

Once `rails new` completes, create/edit a _.env_ file and add:

```
COMPOSE_FILE=docker-compose.yml:docker-compose-postgres.yml
```

and edit _Dockerfile_ to pin the Ruby version to the one in your _Gemfile_
e.g. `FROM ruby` -> `FROM ruby:3.2.2`.

Run:

```
docker-compose up
```

then in another window run:

```
docker-compose exec app ./bin/rails db:setup
```

You will get a warning that "db/schema.rb doesn't exist yet", that's normal as
you don't have any migrations yet.

## Running Rails

```
docker-compose up
```

Your app should be accessible at http://localhost:3000 as usual. Edit files as
you normally would. When you are finished, run `docker-compose down` in another
window.

## Common Tasks

Because Rails lives inside Docker, you need to use `docker compose exec` to run
commands:

- Open the Rails console - `docker-compose exec app ./bin/rails c`
- Adding Gems - `docker-compose exec app bundle add GEM_NAME` (or add the gem manually
  to the Gemfile and run `docker-compose exec app bundle install`.
- Creating migrations - `docker-compose exec app ./bin/rails g migration NAME ...`.
- Running migrations - `docker-compose exec app ./bin/rails db:migrate`.
- Running a shell - `docker-compose exec app bash`.

Debug, Pry, and Byebug can be a bit tricky. You need to "attach" to Docker
first. This can be done by running the following in it's own window:

```
docker attach `docker-compose ls -q`-app-1
```

The when a debugger/byebug/pry statement is reached, you're good to go.

However, there's a catch, **if you hit Control-C in the attached window, you will shutdown the App's
Docker container**.

You can just always leave it attached or type the disconnect sequence Control-P
Control-Q.

## Shell Aliases

These aliases can make it a little easy to work Rails and Docker Compose

```
alias dc='docker-compose
alais dcb='dc exec app bundle'
alias dcr='dcb exec rails
alias dcr='dcb exec rails'
```

With these you can start and stop with `dc up`, and `dc down` and use `dcr console` to get the Rails console or `dcb add GEMNAME` to add a gem.

If you are all in with Docker Compose you could take it a step further with:

```
alias dc='docker-compose'
alias bundle='dc exec app bundle'
alias rails='dcb exec rails'
alias rspec='dcb exec rspec'
```

Note: There is a _dc_ command on most \*nix systems, including macOS, a
"arbitrary-precision decimal reverse-Polish notation calculator". If you happen
to use it, you might want a different name for your alias.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/spikex/rails-on-docker.
This project is intended to be a safe, welcoming space for collaboration
