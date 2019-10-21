Dir["#{Rails.application.config.root}/lib/search/**/*.rb"].each { |f| require(f) }
