require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module GibctDataService
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    #  https://stackoverflow.com/questions/72110385/url-safe-csrf-tokens-are-now-the-default-warning
    config.load_defaults 7.0

    # Configuration for the application, engines, and railties goes here.
    
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.

    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

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

    # Bootstrap support.
    config.assets.paths << "#{Rails}/vendor/assets/fonts"

    config.autoload_paths += Dir["#{config.root}/app/models"]
    config.autoload_paths += Dir["#{config.root}/lib"]
    config.eager_load_paths += Dir["#{config.root}/lib"]
    config.autoload_paths += Dir["#{config.root}/app/utilities"]

    # YAML Defaults for CSV
    config.csv_defaults = YAML.load_file(Rails.root.join('config', 'csv_file_defaults.yml'))

    # Rails 7 upgrade
    # turn off warnings
    # https://stackoverflow.com/questions/76347365/how-do-i-set-legacy-connection-handling-to-false-in-my-rails-application
    config.active_record.legacy_connection_handling = false
  end
end
