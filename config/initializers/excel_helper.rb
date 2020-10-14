Dir["#{Rails.application.config.root}/lib/excel_helper/**/*.rb"].each { |f| require(f) }
