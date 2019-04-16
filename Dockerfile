FROM ruby:latest

RUN mkdir /app
WORKDIR /app
ADD . /app

EXPOSE 4567

ENV APP_ENV production

RUN bundle
