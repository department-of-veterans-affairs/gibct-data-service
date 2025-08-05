# frozen_string_literal: true

module ControllerMacros
  # The system uses current_user, not sure why user was being used instead
  def login_user
    let(:current_user) { FactoryBot.create(:user) }

    before do
      @request.env['devise.mapping'] = Devise.mappings[:user]
      sign_in current_user
    end
  end

  def logout_user
    let(:current_user) { FactoryBot.create(:user) }

    before do
      @request.env['devise.mapping'] = Devise.mappings[:user]
      sign_in current_user
      sign_out current_user
    end
  end
end
