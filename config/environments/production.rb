require 'active_support/core_ext/integer/time'

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.cache_classes = true

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both threaded web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Ensures that a master key has been made available in either ENV["RAILS_MASTER_KEY"]
  # or in config/master.key. This key is used to decrypt credentials (and other encrypted files).
  # config.require_master_key = true

  # Disable serving static files from the `/public` folder by default since
  # Apache or NGINX already handles this.
  config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?

  # Compress JavaScripts and CSS.
  # Do we want to switch to the Terser gem?
  # https://stackoverflow.com/questions/75315372/when-running-rake-assetsprecompile-rails-env-production-over-es6-syntax-pipelin
  #config.assets.js_compressor = Uglifier.new(harmony: true)
  # we ran into deploy errors with Uglifier, new instances kept re-initiating, recommendation to switch to terser as per stackoverflow above
  config.assets.js_compressor = :terser
  # config.assets.css_compressor = :sass

  # Do not fallback to assets pipeline if a precompiled asset is missed.
  config.assets.compile = false

  # Asset digests allow you to set far-future HTTP expiration dates on all assets,
  # yet still be able to expire them through the digest params.
  # rails 7 upgrade note:
  # https://codingitwrong.com/2016/04/15/a-definitive-guide-to-asset-pipeline-settings.html
  # If you have config.assets.compile = false, there are only two combinations of settings that work. 
  # config.assets.debug must be set to false, 
  # config.assets.digest must be set to true
  config.assets.debug = false
  config.assets.digest = true

  # `config.assets.precompile` and `config.assets.version` have moved to config/initializers/assets.rb

  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = 'X-Sendfile' # for Apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for NGINX

  # https://guides.rubyonrails.org/active_storage_overview.html
  # Store uploaded files on the local file system (see config/storage.yml for options).
  # Disable https://stackoverflow.com/questions/49813214/disable-active-storage-in-rails-5-2
  # config.active_storage.service = :local

  # Mount Action Cable outside main process or domain.
  # config.action_cable.mount_path = nil
  # config.action_cable.url = "wss://example.com/cable"
  # config.action_cable.allowed_request_origins = [ "http://example.com", /http:\/\/example.*/ ]

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # We terminate SSL before traffic gets to the gi data service elb and traffic from the elb to the service is over http. So forcing ssl will break our ELB health checks.
  # config.force_ssl = true

  # Use the lowest log level to ensure availability of diagnostic information
  # when problems arise.
  config.log_level = :info

  # Prepend all log lines with the following tags.
  config.log_tags = [ :uuid, :host ]

  # Use a different cache store in production.
  # config.cache_store = :mem_cache_store

  # Use a real queuing backend for Active Job (and separate queues per environment).
  # config.active_job.queue_adapter     = :resque
  # config.active_job.queue_name_prefix = "gibct_data_service_production"
  
  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  # config.action_mailer.raise_delivery_errors = false

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Don't log any deprecations.
  config.active_support.report_deprecations = false

  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = ::Logger::Formatter.new

  # Use a different logger for distributed setups.
  # require "syslog/logger"
  # config.logger = ActiveSupport::TaggedLogging.new(Syslog::Logger.new "app-name")
  # Rails 7 update had this wrapped in an if clause checking to see if ENV["RAILS_LOG_TO_STDOUT"].present?
  # We checked GIBCT production and this variable doesn't exist. We also checked vets-api and they
  # removed the if wrapper around this. So we did too.
  
  STDOUT.sync = config.autoflush_log
  logger = ActiveSupport::Logger.new(STDOUT)
  logger.formatter = config.log_formatter
  config.logger = ActiveSupport::TaggedLogging.new(logger)

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  # We don't do any mailing from this application so the default (false) should be fine.
  config.action_mailer.perform_caching = false
  config.action_mailer.delivery_method = :govdelivery_tms
  config.action_mailer.govdelivery_tms_settings = {
    auth_token: ENV['GOVDELIVERY_TOKEN'],
    api_root: "https://#{ENV['GOVDELIVERY_URL']}"
  }
end
