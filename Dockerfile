# Defaults to the latest Ruby, add ":version" e.g "ruby:3.2.1" to specify
FROM ruby

# Copy the Gemfile and cache the gems. This prevents changes to the source
# from reinstalling gems when the container is rebuild.

WORKDIR /usr/src/app
COPY Gemfile* /usr/src/app/
ENV BUNDLE_PATH /gems
RUN bundle install --jobs 10 --retry 5

# Copy source files
COPY . /usr/src/app/

# Start Rails server, "-b 0.0.0.0" is needed to make it accessable outside
# of the container

CMD ["bin/rails", "s", "-b", "0.0.0.0"]
