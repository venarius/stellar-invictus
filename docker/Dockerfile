FROM ruby:2.5.3-alpine

ENV RAILS_ENV='production'
ENV RACK_ENV='production'

RUN apk add --update --no-cache \
      bash \
      build-base \
      nodejs \
      sqlite-dev \
      tzdata \
      postgresql-dev

RUN gem update bundler

WORKDIR /usr/src/app

COPY Gemfile Gemfile.lock ./
RUN bundle install --jobs 20 --retry 5 --without development test

COPY . .
RUN RAILS_ENV=production bundle exec rake assets:precompile

COPY docker/docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]