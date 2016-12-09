# frozen_string_literal: true
module ControllerMacros
  def login_user
    before(:each) do
      @request.env['devise.mapping'] = Devise.mappings[:user]

      user = FactoryGirl.create(:user)
      sign_in user
    end
  end

  def logout_user
    before(:each) do
      @request.env['devise.mapping'] = Devise.mappings[:user]

      user = FactoryGirl.create(:user)
      sign_in user
      sign_out user
    end
  end
end
