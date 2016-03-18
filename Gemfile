source 'https://rubygems.org'

#ruby=ruby-2.3.0
#ruby-gemset=ingest

# For heroku staging
ruby "2.3.0"
gem 'rails_12factor', '~> 0.0.3', group: :production

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.5.2'

# Use postgresql as the database for Active Record
gem 'pg', '~> 0.15'

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

# Use ActiveModel has_secure_password
# Use devise for authentication
# Use cancancan for authorization
gem 'bcrypt', '~> 3.1.7'
gem 'devise', '~> 3.5', '>= 3.5.6'
gem 'cancancan', '~> 1.13', '>= 1.13.1'

# Pagination
gem 'will_paginate', '~> 3.1'

# Application server: Puma
# Puma was chosen because it handles load of 40+ concurrent users better than Unicorn and Passenger
# Discussion: https://github.com/18F/college-choice/issues/597#issuecomment-139034834
gem 'puma', '~> 2.16'

# Used to colorize output for rake tasks
gem "rainbow"

# Carmen for state names
gem 'carmen-rails', '~> 1.0', '>= 1.0.1'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'

  # Linters
  gem 'rubocop', '~> 0.36.0', require: false
  gem 'scss_lint', require: false
  gem 'jshint', platforms: :ruby

  # Security scanners
  gem 'brakeman'
  gem 'bundler-audit'

  # Testing tools
  gem 'rspec-rails'

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
