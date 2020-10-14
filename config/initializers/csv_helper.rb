Dir["#{Rails.application.config.root}/lib/csv_helper/**/*.rb"].each { |f| require(f) }
