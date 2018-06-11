# frozen_string_literal: true

RSpec.configure do |config|
  config.include Devise::TestHelpers, type: :controller
  config.extend ControllerMacros, type: :controller
end
