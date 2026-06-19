FROM ruby:4.0.3-slim-bookworm

RUN apt-get update -qq && apt-get install -y \
    build-essential \
    postgresql-client \
    libpq-dev \
    libyaml-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /action-note-api

COPY Gemfile Gemfile.lock ./

RUN bundle install

COPY . .

EXPOSE 3001

CMD ["rails", "server", "-b", "0.0.0.0"]

