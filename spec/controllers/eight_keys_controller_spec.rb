require 'rails_helper'

require 'support/controller_macros'
require 'support/devise'
require 'support/shared_examples_for_authentication'

RSpec.describe EightKeysController, type: :controller do
  it_behaves_like "an authenticating controller", :index, "eight_keys"

end
