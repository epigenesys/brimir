# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'simplecov'
SimpleCov.start 'rails'

require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'rspec/rails'
# Add additional requires below this line. Rails is not loaded until this point!

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
# Dir[Rails.root.join('spec', 'support', '**', '*.rb')].each { |f| require f }

# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove these lines.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end
RSpec.configure do |config|
  # Allows us to call FactoryBot methods without doing FactoryBot._
  config.include FactoryBot::Syntax::Methods
  # Let's us use the capybara stuf in our specs
  config.include Capybara::DSL
  # Let's us do login_as(user)
  config.include Warden::Test::Helpers
  config.include Rails.application.routes.url_helpers
  config.include Devise::Test::ControllerHelpers, type: :controller

  # Ensure our database is definitely empty before running the suite
  # (e.g. if a process got killed and things weren't cleaned up)
  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation, { pre_count: true, reset_ids: false })
  end

  # Use transactions for non-javascript tests as it is much faster than truncation
  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
    ActionMailer::Base.deliveries.clear
  end

  # Can't use transaction strategy with Javascript tests because they are run in
  # a separate thread which does not have access to data in an uncommitted transaction.
  config.before(:each, js: true) do
    DatabaseCleaner.strategy = :truncation, { pre_count: true, reset_ids: false }
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    Warden.test_reset!
    DatabaseCleaner.clean
  end

  # Use this to test real error pages (e.g. epiSupport)
  config.around(:each, error_page: true) do |example|
    # Rails caches the action_dispatch setting. Need to remove it for the new setting to apply.
    Rails.application.remove_instance_variable(:@app_env_config) if Rails.application.instance_variable_defined?(:@app_env_config)
    Rails.application.config.action_dispatch.show_exceptions = true
    Rails.application.config.consider_all_requests_local = false

    example.run

    Rails.application.config.action_dispatch.show_exceptions = false
    Rails.application.config.consider_all_requests_local = true
  end

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")
end

Capybara.configure do |config|
  config.server = :puma, { Silent: true }
  config.match  = :prefer_exact
end

Webdrivers.install_dir = Rails.root.join('vendor', 'webdrivers')
Webdrivers.cache_time = 86_400

require 'selenium/webdriver'
Capybara.register_driver :chrome do |app|
  options = ::Selenium::WebDriver::Chrome::Options.new.tap do |opts|
    opts.args << '--headless' unless ENV['SHOW_CHROME']
    opts.args << '--no-sandbox'
    opts.args << '--disable-gpu'
    opts.args << '--disable-dev-shm-usage'
    opts.args << '--disable-infobars'
    opts.args << '--disable-extensions'
    opts.args << '--disable-popup-blocking'
    opts.args << '--window-size=1920,4320'
  end
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end
Capybara.javascript_driver = :chrome

Capybara.asset_host = 'http://localhost:3000'

# Make capybara try and click a radio's label if it can't click the radio itself.
# This takes care of custom radios where the radio itself is not actually visible.
# Also works for checkboxes.
Capybara.automatic_label_click = true
