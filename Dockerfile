FROM phusion/passenger-ruby26:1.0.6

MAINTAINER Vitaliy Korbut <korbut.vitaliy@gmail.com>

# Set correct environment variables.
ENV HOME /root

# Use baseimage-docker's init process.
CMD ["/sbin/my_init"]

# Enable Nginx and Passenger
RUN rm -f /etc/service/nginx/down

# Remove the default site
RUN rm /etc/nginx/sites-enabled/default

# Create virtual host
ADD docker/vhost.conf /etc/nginx/sites-enabled/app.conf

# Prepare folders
RUN mkdir /home/app/og-scraper

# Run Bundle in a cache efficient way https://docs.docker.com/compose/rails/
WORKDIR /tmp
COPY app/Gemfile /tmp/
COPY app/Gemfile.lock /tmp/
RUN bundle install

# Add our app
COPY app /home/app/og-scraper
RUN chown -R app:app /home/app

# Clean up when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
