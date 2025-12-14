FROM ruby:3.4-slim-bookworm

WORKDIR /action-note-api

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential curl dirmngr gnupg libjemalloc2 libvips libpq-dev libyaml-dev && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives \
    && curl -fsSL https://deb.nodesource.com/setup_24.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g yarn \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY Gemfile Gemfile.lock ./

RUN bundle config set --local path vendor/bundle
RUN bundle install --jobs 4 --retry 3

COPY . .

CMD ["/bin/bash", "-c", "rm -f /action-note-api/tmp/pids/server.pid && bundle exec rails s -b 0.0.0.0 -p 3001"]