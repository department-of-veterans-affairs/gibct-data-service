# frozen_string_literal: true
source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.7.1'

# Use postgresql as the database for Active Record
gem 'pg'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use jquery as the JavaScript library
gem 'jquery-rails'
gem 'jquery-ui-rails'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'

# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# Use devise for authentication
gem 'devise'

# Switch from cookie based storage to AR storage in case of failure pushing to GIBCT
gem 'activerecord-session_store'

gem 'figaro'
gem 'travis'

gem 'will_paginate'

# Application server: Puma
# Puma was chosen because it handles load of 40+ concurrent users better than Unicorn and Passenger
# Discussion: https://github.com/18F/college-choice/issues/597#issuecomment-139034834
gem 'puma', '3.2.0'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'

  # Linters
  gem 'jshint', platforms: :ruby
  gem 'rubocop', require: false
  gem 'scss_lint', require: false

  # Security scanners
  gem 'brakeman'
  gem 'bundler-audit'

  # Testing tools
  gem 'rspec-rails'

  # Added to remove irb: context errors on rails c (MPH)
  gem 'guard-rspec', require: false

  gem 'capybara'
  gem 'database_cleaner'
  gem 'factory_girl_rails'
  gem 'faker'
  gem 'simplecov'
  gem 'sniffybara', git: 'https://github.com/department-of-veterans-affairs/sniffybara.git'
  gem 'vcr'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', platforms: :ruby

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring', platforms: :ruby

  # Include the IANA Time Zone Database on Windows, where Windows doens't ship with a timezone database.
  # POSIX systems should have this already, so we're not going to bring it in on other platforms
  gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
end

# Used to colorize output for rake tasks
gem 'rainbow'
