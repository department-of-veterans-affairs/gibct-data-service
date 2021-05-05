# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApiController, type: :controller do
  subject(:api_controller) { JSON.parse(response.body)['errors'].first }

  controller do
    def parameter_missing
      params.require(:missing_param)
    end

    def internal_server_error
      10 / 0
    end

    def unauthorized
      raise Common::Exceptions::Unauthorized
    end
  end

  let(:keys_for_all_env) { %w[title detail code status] }
  let(:keys_for_with_meta) { keys_for_all_env + ['meta'] }

  context 'when Parameter Missing' do
    before do
      routes.draw { get 'parameter_missing' => 'api#parameter_missing' }
      create(:version, :production)
    end

    context 'with Rails.env.test or Rails.env.development' do
      it 'renders json object with developer attributes' do
        get :parameter_missing
        expect(api_controller.keys).to eq(keys_for_all_env)
      end
    end

    context 'with Rails.env.production' do
      it 'renders json error with production attributes' do
        allow(Rails)
          .to(receive(:env))
          .and_return(ActiveSupport::StringInquirer.new('production'))

        get :parameter_missing
        expect(api_controller.keys)
          .to eq(keys_for_all_env)
      end
    end
  end

  context 'when Internal Server Error' do
    before do
      routes.draw { get 'internal_server_error' => 'api#internal_server_error' }
      create(:version, :production)
    end

    context 'with Rails.env.test or Rails.env.development' do
      it 'renders json object with developer attributes' do
        get :internal_server_error
        expect(api_controller.keys).to eq(keys_for_with_meta)
      end
    end

    context 'with Rails.env.production' do
      it 'renders json error with production attributes' do
        allow(Rails)
          .to(receive(:env))
          .and_return(ActiveSupport::StringInquirer.new('production'))

        get :internal_server_error
        expect(api_controller.keys)
          .to eq(keys_for_all_env)
      end
    end
  end

  context 'when Unauthorized' do
    before do
      routes.draw { get 'unauthorized' => 'api#unauthorized' }
      create(:version, :production)
    end

    context 'with Rails.env.test or Rails.env.development' do
      it 'renders json object with developer attributes' do
        get :unauthorized
        expect(api_controller.keys).to eq(keys_for_all_env)
      end
    end

    context 'with Rails.env.production' do
      it 'renders json error with production attributes' do
        allow(Rails)
          .to(receive(:env))
          .and_return(ActiveSupport::StringInquirer.new('production'))

        get :unauthorized
        expect(api_controller.keys)
          .to eq(keys_for_all_env)
        expect(response.headers['WWW-Authenticate'])
          .to eq('Token realm="Application"')
      end
    end
  end
end
