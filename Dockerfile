# This template builds two images, to optimise caching:
# builder: builds gems and node modules
# production: runs the actual app

# Build builder image
FROM ruby:3.3.5-alpine3.20 AS builder

# RUN apk -U upgrade && \
#     apk add --update --no-cache gcc git libc6-compat libc-dev make nodejs \
#     postgresql13-dev yarn

WORKDIR /app

# Add the timezone (builder image) as it's not configured by default in Alpine
RUN apk add --update --no-cache tzdata && \
  cp /usr/share/zoneinfo/Europe/London /etc/localtime && \
  echo "Europe/London" > /etc/timezone

# build-base: dependencies for bundle
# yarn: node package manager
# postgresql-dev: postgres driver and libraries
# git: to install dfe-analytics
RUN apk add --no-cache build-base yarn postgresql14-dev git

# Install gems defined in Gemfile
COPY .ruby-version Gemfile Gemfile.lock ./

# Install gems and remove gem cache
RUN bundler -v && \
  bundle config set no-cache 'true' && \
  bundle config set no-binstubs 'true' && \
  bundle config set without 'development test' && \
  bundle install --retry=5 --jobs=4 && \
  rm -rf /usr/local/bundle/cache

# Install node packages defined in package.json
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile --check-files

# Copy all files to /app (except what is defined in .dockerignore)
COPY . .

# Precompile assets
RUN RAILS_ENV=production SECRET_KEY_BASE=required-to-run-but-not-used \
  bundle exec rails assets:precompile

# Cleanup to save space in the production image
RUN rm -rf node_modules log/* tmp/* /tmp && \
  rm -rf /usr/local/bundle/cache && \
  rm -rf .env && \
  find /usr/local/bundle/gems -name "*.c" -delete && \
  find /usr/local/bundle/gems -name "*.h" -delete && \
  find /usr/local/bundle/gems -name "*.o" -delete && \
  find /usr/local/bundle/gems -name "*.html" -delete

# Build runtime image
FROM ruby:3.3.5-alpine AS production

# Use rails production environment when deployed using docker
ENV RAILS_ENV=production
# The application runs from /app
WORKDIR /app

# Add the timezone (prod image) as it's not configured by default in Alpine
RUN apk add --update --no-cache tzdata && \
  cp /usr/share/zoneinfo/Europe/London /etc/localtime && \
  echo "Europe/London" > /etc/timezone

# libpq: required to run postgres
RUN apk add --no-cache libpq

# proj-util: provides cs2cs, required by Gias::CSVTransformer::CoordinateTransformer
RUN apk add --no-cache proj-util

# Copy files generated in the builder image
COPY --from=builder /app /app
COPY --from=builder /usr/local/bundle/ /usr/local/bundle/

# Set the SHA environment variable for the healthcheck
ARG COMMIT_SHA
ENV SHA=${COMMIT_SHA}

CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
