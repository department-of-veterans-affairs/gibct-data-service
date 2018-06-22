# frozen_string_literal: true
require 'rails_helper'
require 'support/controller_macros'
require 'support/devise'

RSpec.describe ApplicationController, type: :controller do
  let!(:user) { create(:user) }

  describe 'current_user' do
    context 'with user logged in' do
      before do
        session[:user_id] = user.id
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
      end

      it 'home redirects to dashboards path' do
        expect(get(:home)).to redirect_to(dashboards_path)
      end
    end

    context 'without user logged in' do
      it 'home redirects to login path' do
        expect(get(:home)).to redirect_to(new_user_session_path)
      end
    end
  end
end
