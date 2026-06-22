ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

require 'bundler/setup' # Set up gems listed in the Gemfile.
require 'logger' # This is required to support concurrent-ruby >= 1.3.5 and Rails 6.0
require 'bootsnap/setup' # Speed up boot time by caching expensive operations.
