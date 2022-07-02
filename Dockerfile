FROM ruby:3.1

LABEL maintainer="hi@joaobruno.xyz"
ENV REFRESHED_AT 2022-07-01

WORKDIR /usr/src/app

COPY . .

RUN bundle install