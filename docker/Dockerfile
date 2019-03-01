FROM phusion/passenger-ruby25:1.0.3

ENV HOME /root
ENV RAILS_ENV 'production'

CMD ["/sbin/my_init"]

RUN gem update bundler

WORKDIR /home/app/webapp

COPY --chown=app:app Gemfile Gemfile.lock ./
RUN rvm-exec 2.5.3 bundle install --jobs 20 --retry 5 --without development test

COPY --chown=app:app . /home/app/webapp
RUN rvm-exec 2.5.3 bundle exec rake assets:precompile

RUN rm /etc/nginx/sites-enabled/default
ADD docker/webapp.conf /etc/nginx/sites-enabled/webapp.conf
ADD docker/secret_keys.conf /etc/nginx/main.d/secret_key.conf
ADD docker/gzip_max.conf /etc/nginx/conf.d/gzip_max.conf

RUN mkdir -p /etc/my_init.d
COPY --chown=app:app docker/docker-entrypoint.sh /etc/my_init.d/
RUN chmod +x /etc/my_init.d/docker-entrypoint.sh
ENTRYPOINT ["/etc/my_init.d/docker-entrypoint.sh"]

RUN rm -f /etc/service/nginx/down

COPY --chown=app:app certificates/* /etc/nginx/ssl/

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*