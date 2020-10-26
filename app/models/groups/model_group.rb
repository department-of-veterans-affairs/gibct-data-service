# frozen_string_literal: true

# This should not have to be here but ruby is not loading this in config/initializers/roo_helper.rb
Dir["#{Rails.application.config.root}/lib/roo_helper/**/*.rb"].sort.each { |f| require(f) }

class ModelGroup
  include RooHelper

end
