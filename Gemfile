source 'https://rubygems.org'

gem 'rails', '5.2.4.5'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

gem 'sass-rails', '~> 5.0.7'
gem 'coffee-rails', '~> 4.2.2'

gem 'uglifier', "~> 3.0.0"

gem 'compass-rails', '~> 3.0.2'
gem 'foundation-rails', '~> 5.5.3', '>= 5.5.3.2'

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

group :test do
  gem 'puma'

  gem 'timecop'
  gem 'simplecov'

  # We need this to not break the test suite as `assigns` and `assert_template` have been remove and extracted to a gem in Rails 5
  gem 'rails-controller-testing', '>= 1.0.4'
  gem 'factory_bot_rails', '>= 5.1.1'

  gem 'shoulda-matchers'
  gem 'capybara', '>= 3.28.0'
  gem 'database_cleaner'
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

# 2.7.0 appears to have regressions that are fixed in 2.7.1
gem 'mail'

# omniauth
# TODO: 2.0.0 is not supported in Devise yet
gem 'omniauth', '< 2.0.0'
gem 'omniauth-rails_csrf_protection', '< 1.0.0'

gem 'omniauth-google-oauth2'

# authorization
gem 'cancancan', '~> 2.1', '>= 2.1.4'

# pagination
gem 'will_paginate', "~> 3.1"

# attachments, thumbnails etc
gem 'paperclip', "~> 6.1"

# select2 replacement for selectboxes
gem 'select2-rails', '~> 3.5' # newer breaks Foundation Reveal on tickets#show

gem 'font-awesome-rails', '~> 4.7', '>= 4.7.0.5'

# for language detection
gem 'http_accept_language', "~> 2.1"

# internationalisation
gem 'rails-i18n', '~> 5.1', '>= 5.1.3'
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
gem 'digest-sha3'

# Trix WYSIWYG editor
gem 'trix-rails', '~> 0.11', '>= 0.11.4.1', require: 'trix'

# React support
gem 'react-rails', '~> 1.11', '>= 1.11.0'

# Capistrano for deployment
group :development do
  gem 'capistrano', '~> 3.8'
  gem 'capistrano-rails', require: false
  gem 'capistrano-bundler', require: false
end
