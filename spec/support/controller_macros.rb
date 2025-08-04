# frozen_string_literal: true

module ControllerMacros
  def login_user
    before do
      @request.env['devise.mapping'] = Devise.mappings[:user]

      user = FactoryBot.create(:user)
      sign_in user
    end
  end

  def logout_user
    before do
      @request.env['devise.mapping'] = Devise.mappings[:user]

      user = FactoryBot.create(:user)
      sign_in user
      sign_out user
    end
  end
end
