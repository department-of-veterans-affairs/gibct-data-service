# frozen_string_literal: true

source 'https://rubygems.org'

gem 'rails', '8.1.1'

gem 'active_model_serializers', '~> 0.10.15' # JSON API
gem 'activerecord-import' # Mass importing of CSV data
gem 'activerecord-session_store' # Switch to AR session storage in case of failure pushing to GIBCT
gem 'base64', '~> 0.2.0' # ruby 3.4.0 warning said to add
gem 'bcrypt', '~> 3.1.20'
gem 'bootsnap', require: false
gem 'cancancan', '~> 3.6' # Use cancancan for authorization
gem 'cgi', '>= 0.4.2'
gem 'config'
gem 'csv', '~> 3.3' # ruby 3.4.0 warning said to add
gem 'devise' # Use devise for authentication
gem 'drb', '~> 2.2', '>= 2.2.1' # ruby 3.4.0 warning said to add
gem 'faraday'
gem 'faraday_middleware'
gem 'figaro'
gem 'font-awesome-rails', '4.7.0.9'
gem 'geocoder', '~> 1.8'
gem 'govdelivery-tms', '2.8.4', require: 'govdelivery/tms/mail/delivery_method'
gem 'httparty'
gem 'importmap-rails'
gem 'jquery-rails'
gem 'jquery-ui-rails', '>= 8.0.0'
gem 'json', '>= 2.3.0'
gem 'mutex_m', '~> 0.3.0' # ruby 3.4.0 warning said to add
gem 'net-imap', '~> 0.5.8' # ruby 3.4.0 warning said to add
gem 'newrelic_rpm'
gem 'nokogiri', '~> 1.18.9'
gem 'oj' # Amazon Linux `json` gem causes conflicts, but `multi_json` will prefer `oj` if installed
gem 'pg' # Use postgresql as the database for Active Record
gem 'puma', '~> 6.6.1'
gem 'rack', '>= 3.1.17'
gem 'rack-cors', require: 'rack/cors' # CORS
gem 'rails-html-sanitizer', '>= 1.4.4'
gem 'rainbow'
gem 'rexml', '~> 3.4.1'
gem 'roo', '~> 2.10'
gem 'roo-xls', '~> 1.2'
gem 'ruby-saml', '>= 1.18.0'
gem 'rubyzip', '~> 2.4'
gem 'sentry-raven', '~> 3.1.2'
gem 'sitemap_generator'
gem 'solid_cache', '~> 0.7.0'
gem 'sprockets-rails' # Rails 7 upgrade - needed for now.
gem 'strong_migrations'
gem 'terser'
gem 'turbo-rails'
gem 'vets_json_schema', git: 'https://github.com/department-of-veterans-affairs/vets-json-schema', branch: 'master'
gem 'virtus', '~> 2.0.0'
gem 'will_paginate'

group :production do
  gem 'sass-rails', '6.0'
end

group :development, :test do
  gem 'byebug' # Call 'byebug' anywhere in the code to get a debugger console
  gem 'pry-nav'

  # Linters
  gem 'libv8-node', '21.7.2.0'
  gem 'mini_racer'
  gem 'rubocop', require: false
  gem 'rubocop-rails'
  gem 'rubocop-rspec'
  gem 'scss_lint', require: false

  # Security scanners
  gem 'brakeman'
  gem 'bundler-audit'

  # Testing tools
  gem 'headless', '~> 2.3.1' # requires xvfb - used with Watir below
  gem 'json_matchers'
  gem 'rails-controller-testing'
  gem 'rspec-rails'
  gem 'watir', '~> 7.3'

  # Added to remove irb: context errors on rails c (MPH)
  gem 'guard-rspec', require: false

  gem 'factory_bot_rails', '> 5'

  gem 'capybara', '3.40.0'
  gem 'database_cleaner'
  gem 'faker', '~> 3.5'
  gem 'parallel_tests'
  gem 'simplecov'
  gem 'simplecov-single_file', require: false, group: :test
  gem 'vcr', '~> 6.3'
  gem 'webmock'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 4.2', platforms: :ruby

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'spring', platforms: :ruby
end

gem 'mission_control-jobs'
gem 'solid_queue', '~> 1.1'
