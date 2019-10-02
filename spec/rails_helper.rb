# frozen_string_literal: true

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../config/environment', __dir__)
# Prevent database truncation if the environment is production
abort('The Rails environment is running in production mode!') if Rails.env.production?
require 'spec_helper'
require 'rspec/rails'
require 'support/serializer_spec_helper'
require 'support/site_mapper_helper'

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
# Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

# Checks for pending migration and applies them before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!

require 'capybara/rspec'
Capybara.default_driver = :sniffybara
Capybara.javascript_driver = :webkit_debug

RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  # config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # Adding capybara DSL to rspec
  config.include Capybara::DSL

  # Serializer specs
  config.include SerializerSpecHelper, type: :serializer

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  # Allow short form of FactoryBot calls.
  config.include FactoryBot::Syntax::Methods

  # Allow skip_before_action in rspec controller tests
  config.include Devise::Test::ControllerHelpers, type: :controller

  config.include Warden::Test::Helpers, type: :request

  # database_cleaner configuration
  # Clear the entire DB before tests begin
  config.before(:suite) do
    # rubocop:disable Style/StringLiterals
    puts "***********************************************"
    puts ENV['CI']
    puts ENV['CI'].present?
    puts "***********************************************"
    # rubocop:enable Style/StringLiterals
    DatabaseCleaner.allow_remote_database_url = ENV['CI'].present?
    DatabaseCleaner.clean_with(:truncation)
  end

  # Run each test in a transaction
  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  # Only runs before examples which have been flagged :js => true.
  # By default, they are generally used for Capybara tests which use a
  # javascript headless webkit such as Selenium. For these types of tests,
  # transactions won't work, so this code overrides the setting and
  # chooses the truncation strategy instead. (MPH)
  config.before(:each, js: true) do
    DatabaseCleaner.strategy = :truncation
  end

  # Cause database_cleaner to start before each test. (MPH)
  config.before(:each) do
    DatabaseCleaner.start
  end

  # Cause database_cleaner to clean database with selected strategy after
  # each test. (MPH)
  config.after(:each) do
    DatabaseCleaner.clean
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
