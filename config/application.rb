require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module GibctDataService
  class Application < Rails::Application
    config.load_defaults '7.0' # enables zeitwerk mode in CRuby

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w(assets tasks))

    # Configuration for the application, engines, and railties goes here.
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.

    # config.time_zone = 'Eastern Time (US & Canada)'
    # config.eager_load_paths << Rails.root.join("extras")

    # CORS configuration; see also cors_preflight route
    config.middleware.insert_before 0, Rack::Cors, logger: (-> { Rails.logger }) do
      allow do
        regex = Regexp.new(Settings.web_origin_regex)
        origins { |source, _env| Settings.web_origin.split(',').include?(source) || source.match?(regex) }
        resource '*', headers: :any, methods: :any, credentials: true
      end
    end

    # Serve all defaults except X-XSS-Protection which is served by reverse proxy
    config.action_dispatch.default_headers = {
      'X-Frame-Options' => 'SAMEORIGIN',
      'X-Content-Type-Options' => 'nosniff'
    }

    # Bootstrap support.
    config.assets.paths << "#{Rails}/vendor/assets/fonts"

    config.autoload_paths += Dir["#{config.root}/lib"]
    config.eager_load_paths += Dir["#{config.root}/lib"]

    # YAML Defaults for CSV
    config.csv_defaults = YAML.load_file(Rails.root.join('config', 'csv_file_defaults.yml'))

    # Rails 7 upgrade - turn off warnings
    # https://stackoverflow.com/questions/76347365/how-do-i-set-legacy-connection-handling-to-false-in-my-rails-application
    # the legacy_connection_handling configuration option, which was deprecated in Rails 7.0 and removed in Rails 7.1
    # config.active_record.legacy_connection_handling = false
  end
end
