Dir["#{Rails.application.config.root}/lib/common/**/*.rb"].each { |f| require(f) }
