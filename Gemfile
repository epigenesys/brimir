source 'https://rubygems.org'
ruby_major, ruby_minor, _ = RUBY_VERSION.split('.').map { |part| Integer(part) }

gem 'rails', '>= 6.0.4.6', '< 6.1'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

gem 'sass-rails'
gem 'coffee-rails'
if ruby_major < 3
  # Stop sprockets importing base64
  gem 'sprockets', '<= 3.7.2'
else
  gem 'sprockets', '< 4.0'
end

gem 'uglifier', "~> 3.0.0"

gem 'foundation-rails', '< 6.0'

gem 'jquery-rails', '~> 4.3', '>= 4.3.5'
gem 'jquery-visibility-rails'

# foundation form errors
gem 'foundation_rails_helper', '~> 2.0', '>= 2.0.0'

# Testing
group :development, :test do
  gem 'rspec-rails', '>= 3.9.0'
  gem 'byebug', '~> 10.0'
  gem 'pry', "~> 0.11"
end

group :development do
  # Spring application pre-loader
  gem 'spring', "~> 2.0"

  # open sent emails in the browser
  gem 'letter_opener', "~> 1.4"

  gem 'annotate'
end

gem 'puma'

group :test do
  gem 'timecop'
  gem 'simplecov'

  # We need this to not break the test suite as `assigns` and `assert_template` have been remove and extracted to a gem in Rails 5
  gem 'rails-controller-testing', '>= 1.0.4'
  gem 'factory_bot_rails', '>= 5.1.1'

  gem 'shoulda-matchers'
  gem 'capybara', '>= 3.28.0'
  gem 'database_cleaner', '< 1.99.0'
  gem 'selenium-webdriver'
  gem 'webdrivers', '>= 4.1.2'
  gem 'launchy'
end

# Optional PostgreSQL for production
gem 'pg', group: :postgresql
# Optional MySQL for production
gem 'mysql2', "~> 0.4", group: :mysql

# authentication
gem 'devise'
gem 'devise_ldap_authenticatable'

# concurrent-ruby >= 1.3.5 is not compatible with Rails 6.0
gem 'concurrent-ruby', '1.3.4'

# This is required as connection_pool >= 3.0 is not compatible with Rails 6.0
gem 'connection_pool', '< 3.0'

if ruby_major < 3
  # This is required in Ruby 2.x to fix mail 2.8.x requiring new net-* gems
  gem 'mail', '< 2.8.0'
else
  gem 'mail', '>= 2.8.0'

  if ruby_minor >= 1
    gem 'nokogiri', '>= 1.18.9'
  end

  if ruby_minor == 3
    gem 'base64',     '0.2.0'
    gem 'bigdecimal', '3.1.5'
    gem 'mutex_m',    '0.2.0'
  elsif ruby_minor >= 4
    gem 'base64',     '>= 0.2.0'
    gem 'bigdecimal', '>= 3.1.8'
    gem 'drb',        '>= 2.2.1'
    gem 'mutex_m',    '>= 0.3.0'
    gem 'observer',   '>= 0.1.2'
  end
end

# omniauth
# TODO: 2.0.0 is not supported in Devise yet
gem 'omniauth', '< 2.0.0'
gem 'omniauth-rails_csrf_protection', '< 1.0.0'

gem 'omniauth-google-oauth2'

# authorization
gem 'cancancan'

# pagination
gem 'will_paginate', "~> 3.1"

# attachments, thumbnails etc
gem 'kt-paperclip', "< 7.0"

# select2 replacement for selectboxes
gem 'select2-rails', '~> 3.5' # newer breaks Foundation Reveal on tickets#show

gem 'font-awesome-rails', '~> 4.7', '>= 4.7.0.5'

# for language detection
gem 'http_accept_language', "~> 2.1"

# internationalisation
gem 'rails-i18n'
gem 'devise-i18n', '~> 1.8', '>= 1.8.2'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.6'

# fancybox for showing image in lightbox
gem 'fancybox2-rails', '~> 0.2', '>= 0.2.7'

# Captcha for brimir
gem 'recaptcha', "~> 4.0", require: 'recaptcha/rails'

# talk to RESTful services
gem 'rest-client', '~> 2.0'

# secure digest
gem 'keccak'

# Trix WYSIWYG editor
gem 'trix-rails', require: 'trix'

# React support
gem 'react-rails', '~> 1.11', '>= 1.11.0'

# Capistrano for deployment
group :development do
  gem 'capistrano', '~> 3.8'
  gem 'capistrano-rails', require: false
  gem 'capistrano-bundler', require: false

  gem 'brakeman'
  gem 'bundler-audit', '>= 0.9.0.1'
end

# Psych (4.0+ is broken re: aliases)
gem 'psych', '~> 3.0'
