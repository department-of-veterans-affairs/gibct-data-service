Dir["#{Rails.application.config.root}/lib/facets/**/*.rb"].each { |f| require(f) }
