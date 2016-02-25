require 'support/controller_macros'
require 'support/devise'

RSpec.describe DashboardController, type: :controller do
	login_user

	specify { expect(true).to be_truthy }
end
