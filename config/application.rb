require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module GibctDataService
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Eastern Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # CORS configuration; see also cors_preflight route
    config.middleware.insert_before 0, Rack::Cors, logger: (-> { Rails.logger }) do
      allow do
        origins 'localhost:3001', 'localhost:3000', 'localhost'
        resource '/v0/*', headers: :any, methods: :any, credentials: true
      end
    end

    # Serve all defaults except X-XSS-Protection which is served by reverse proxy
    config.action_dispatch.default_headers = {
      'X-Frame-Options' => 'SAMEORIGIN',
      'X-Content-Type-Options' => 'nosniff'
    }

    # Do not swallow errors in after_commit/after_rollback callbacks.
    # config.active_record.raise_in_transactional_callbacks = true

    # Bootstrap support.
    config.assets.paths << "#{Rails}/vendor/assets/fonts"

    # SmarterCsv converter support
    config.autoload_paths += %W(#{config.root}/app/models/converters)

    # YAML Defaults for CSV
    config.csv_defaults = YAML.load_file(Rails.root.join('config', 'csv_file_defaults.yml'))
  end
end
