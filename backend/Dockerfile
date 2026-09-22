FROM ruby:3.3-slim

# Install system dependencies
RUN apt-get update -qq && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    curl \
    git \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install gems
COPY Gemfile Gemfile.lock* /app/
RUN bundle install

# Copy application code
COPY . /app

EXPOSE 3001

CMD ["bundle", "exec", "rails", "s", "-b", "0.0.0.0", "-p", "3001"]
