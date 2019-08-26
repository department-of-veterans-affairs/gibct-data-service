source 'https://rubygems.org'

# Anchored versions, do not change

# Application server: Puma
# Puma was chosen because it handles load of 40+ concurrent users better than Unicorn and Passenger
# Discussion: https://github.com/18F/college-choice/issues/597#issuecomment-139034834
gem 'puma', '~> 3.6'

gem 'rails', '~> 4.2.11'


# Gems with special version/repo needs

# JSON API
gem 'active_model_serializers', '~> 0.10.4'

# Switch from cookie based storage to AR storage in case of failure pushing to GIBCT
gem 'activerecord-session_store', '~> 1.0'

gem 'bcrypt', '~> 3.1.7'
# Use cancancan for authorization
gem 'cancancan', '~> 1.13', '>= 1.13.1'
gem 'govdelivery-tms', '2.8.4', require: 'govdelivery/tms/mail/delivery_method'
# Use postgresql as the database for Active Record
gem 'pg', '~> 0.15'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rubyzip', '~> 1.2', '>= 1.2.1'
gem 'sentry-raven', '~> 2.3.0'

# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc
gem 'sitemap_generator', '~> 5.3', '>= 5.3.1'
gem 'smarter_csv', '1.1.4'
gem 'uglifier', '>= 1.3.0'
gem 'virtus', '~> 1.0.5'


# Mass importing of CSV data
gem 'activerecord-import'

gem 'config'

# Use devise for authentication
gem 'devise'
gem 'figaro'
gem 'font-awesome-rails'
gem 'jquery-rails'
gem 'jquery-ui-rails'

# CORS
gem 'rack-cors', :require => 'rack/cors'

gem 'rainbow'

# Use ActiveModel has_secure_password
gem 'ruby-saml'

gem 'strong_migrations'
gem 'will_paginate'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
  gem 'pry-nav'

  # Linters
  gem 'rubocop', '~> 0.53.0', require: false
  gem 'scss_lint', require: false
  gem 'jshint', platforms: :ruby

  # Security scanners
  gem 'brakeman', '3.4.1'
  gem 'bundler-audit', '0.5.0'

  # Testing tools
  gem 'rspec-rails'
  gem 'json_matchers'

  # Added to remove irb: context errors on rails c (MPH)
  gem 'guard-rspec', require: false

  gem 'factory_bot_rails'

  gem 'capybara', '2.11.0'
  gem 'sniffybara', git: 'https://github.com/department-of-veterans-affairs/sniffybara.git', ref: 'e355cfde5ae039601b3f273fe07c1b36a129c4c6'
  gem 'simplecov'
  gem 'database_cleaner', '1.5.3'
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
