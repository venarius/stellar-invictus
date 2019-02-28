FROM phusion/passenger-ruby25:1.0.3

# Set correct environment variables.
ENV HOME /root

# Use baseimage-docker's init process.
CMD ["/sbin/my_init"]

# Setting ENV
ENV RAILS_ENV='production'
ENV RACK_ENV='production'

# Custom Lines
COPY Gemfile* /home/app/webapp/
WORKDIR /home/app/webapp
RUN bundle install --jobs 20 --retry 5 --without development test
COPY --chown=app:app . /home/app/webapp

RUN bundle exec rake assets:precompile

# Set custom Nginx Config
RUN rm /etc/nginx/sites-enabled/default
ADD docker/webapp.conf /etc/nginx/sites-enabled/webapp.conf
COPY certificates/* /etc/nginx/ssl/

# Enable Nginx and Passenger
RUN rm -f /etc/service/nginx/down

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
