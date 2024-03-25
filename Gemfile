# frozen_string_literal: true

source 'https://rubygems.org'

ruby '3.2.2'

# Anchored versions, do not change

# Application server: Puma
# Puma was chosen because it handles load of 40+ concurrent users better than Unicorn and Passenger
# Discussion: https://github.com/18F/college-choice/issues/597#issuecomment-139034834
gem 'puma', '~> 5.6.8'
gem 'rails', '~> 7.0.8.1'

# Gems with special version/repo needs

# JSON API
gem 'active_model_serializers', '~> 0.10.4'

gem 'bcrypt', '~> 3.1.7'
# Use cancancan for authorization
gem 'cancancan', '~> 1.13', '>= 1.13.1'
gem 'geocoder', '~> 1.3', '>= 1.3.7'
gem 'govdelivery-tms', '2.8.4', require: 'govdelivery/tms/mail/delivery_method'
gem 'json', '>= 2.3.0'
# Use postgresql as the database for Active Record
gem 'nokogiri', '~> 1.16.2'
gem 'pg'
gem 'roo', '~> 2.8'
gem 'roo-xls', '~> 1.2'
gem 'rubyzip', '~> 2.3'
gem 'sentry-raven', '~> 2.9.0'
gem 'uglifier', '>= 1.3.0'
gem 'vets_json_schema', git: 'https://github.com/department-of-veterans-affairs/vets-json-schema', branch: 'master'
gem 'virtus', '~> 1.0.5'
# Mass importing of CSV data
gem 'activerecord-import'
# Switch from cookie based storage to AR storage in case of failure pushing to GIBCT
gem 'activerecord-session_store'

gem 'config'
gem 'sprockets-rails'

# Use devise for authentication
gem 'devise'
gem 'faraday'
gem 'faraday_middleware'
gem 'figaro'
gem 'font-awesome-rails'
gem 'jquery-rails'
gem 'jquery-ui-rails', git: 'https://github.com/jquery-ui-rails/jquery-ui-rails', branch: 'master'
gem 'newrelic_rpm'
gem 'oj' # Amazon Linux `json` gem causes conflicts, but `multi_json` will prefer `oj` if installed

# CORS
gem 'rack-cors', require: 'rack/cors'
gem 'rainbow'

# Use ActiveModel has_secure_password
gem 'rack', '>= 2.2.8.1'
gem 'rails-html-sanitizer', '>= 1.4.4'
gem 'ruby-saml'
gem 'sitemap_generator'
gem 'strong_migrations'
gem 'whenever', require: false
gem 'will_paginate'

group :production do
  gem 'sass-rails', '6.0'
end

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
  gem 'pry-nav'

  # Linters
  gem 'libv8-node', '16.10.0.0'
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

  gem 'capybara', '2.11.0'
  gem 'database_cleaner'
  gem 'faker', '~> 3.1', '>= 3.1.1'
  gem 'parallel_tests'
  gem 'simplecov'
  gem 'simplecov-single_file', require: false, group: :test
  gem 'vcr', '~> 3.0', '>= 3.0.1'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0', platforms: :ruby

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring', platforms: :ruby

  # Include the IANA Time Zone Database on Windows, where Windows doens't ship with a timezone database.
  # POSIX systems should have this already, so we're not going to bring it in on other platforms
  gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
end
