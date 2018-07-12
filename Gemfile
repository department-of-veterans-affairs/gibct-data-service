source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.7.1'
gem 'rubyzip', '~> 1.2', '>= 1.2.1'

# Use postgresql as the database for Active Record
gem 'pg', '~> 0.15'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use jquery as the JavaScript library
gem 'jquery-rails'
gem 'jquery-ui-rails'

# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# Use ActiveModel has_secure_password
# Use devise for authentication
# Use cancancan for authorization
gem 'bcrypt', '~> 3.1.7'
gem 'devise', '~> 3.5', '>= 3.5.6'
gem 'cancancan', '~> 1.13', '>= 1.13.1'
gem 'ruby-saml'

# Switch from cookie based storage to AR storage in case of failure pushing to GIBCT
gem 'activerecord-session_store', '~> 1.0'

# CORS
gem 'rack-cors', :require => 'rack/cors'

# Mass importing of CSV data
gem 'activerecord-import'
gem 'smarter_csv'

# Pagination
gem 'will_paginate'

# JSON API
gem 'active_model_serializers', '~> 0.10.4'
gem 'virtus', '~> 1.0.5'

# Provides country/state support
# gem 'carmen'

# Application server: Puma
# Puma was chosen because it handles load of 40+ concurrent users better than Unicorn and Passenger
# Discussion: https://github.com/18F/college-choice/issues/597#issuecomment-139034834
gem "puma", "~> 3.6"
gem 'figaro'

# Sentry
gem 'sentry-raven', '~> 2.3.0'

gem 'zero_downtime_migrations'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
  gem 'pry-nav'

  # Linters
  gem 'rubocop', '~> 0.52.1', require: false
  gem 'scss_lint', require: false
  gem 'jshint', platforms: :ruby

  # Security scanners
  gem 'brakeman'
  gem 'bundler-audit'

  # Testing tools
  gem 'rspec-rails'
  gem "json_matchers"

  # Added to remove irb: context errors on rails c (MPH)
  gem 'guard-rspec', require: false

  gem 'capybara'
  gem 'sniffybara', git: 'https://github.com/department-of-veterans-affairs/sniffybara.git'
  gem 'simplecov'
  gem 'factory_girl_rails', '~> 4.6'
  gem 'database_cleaner', '~> 1.5', '>= 1.5.1'
  gem 'faker', '~> 1.6', '>= 1.6.2'
  gem 'vcr', '~> 3.0', '>= 3.0.1'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0', platforms: :ruby

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring', platforms: :ruby

  # Include the IANA Time Zone Database on Windows, where Windows doens't ship with a timezone database.
  # POSIX systems should have this already, so we're not going to bring it in on other platforms
 gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
end

# Used to colorize output for rake tasks
gem "rainbow"

# Build sitemap
gem 'sitemap_generator', '~> 5.3', '>= 5.3.1'
