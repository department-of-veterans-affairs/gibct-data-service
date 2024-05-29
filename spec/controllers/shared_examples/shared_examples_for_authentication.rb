# frozen_string_literal: true

RSpec.shared_examples 'an authenticating controller' do |action, destination, params = nil|
  describe 'when being visited' do
    context 'when not authenticated' do
      it 'redirects the user to login page' do
        get action, params: params

        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(new_user_session_url)
      end
    end

    context 'when submitting credentials' do
      let(:bad_user) { build :user, :bad_email }

      it 'outputs an error message if not successful' do
        visit user_session_path

        fill_in 'Email', with: bad_user.email
        fill_in 'Password', with: bad_user.password

        click_button 'Log in'

        expect(page).to have_content('Invalid Email or password')
      end
    end

    context 'when authenticated' do
      login_user

      it "sends that user to the #{destination}/#{action}" do
        expect(get(action, params: params)).to render_template("#{destination}/#{action}")
      end

      it 'has a current user' do
        expect(subject.current_user).not_to be_nil
      end
    end
  end

  describe 'and when logging out' do
    logout_user

    it 'nulls the current user' do
      expect(subject.current_user).to be_nil
    end
  end
end
