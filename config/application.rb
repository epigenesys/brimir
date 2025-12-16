# This is required as Bootsnap does not work properly with Ruby 3.3.1
require_relative '../lib/monkey_patches/rubygems_bundled_gems_warning'

require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Brimir
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Change this to :ldap_authenticatable to use ldap
    config.devise_authentication_strategy = :database_authenticatable
    config.i18n.default_locale = :en
    config.i18n.available_locales = %i(ar de en es fa fi fr-CA fr-FR nb nl pt-BR ru uk zh-CN)
    config.i18n.fallbacks = %i(en)

    raise "Check `default_query_parser` works for Rack >= 3.x" if Gem::Version.new(Rack::RELEASE) >= Gem::Version.new('2.3')
    Rack::Utils.default_query_parser = Rack::QueryParser.make_default(
      Rack::Utils.key_space_limit,
      Rack::Utils.param_depth_limit,
      bytesize_limit: 1024 * 1024 * 10, # 10 MB
    )
  end
end
