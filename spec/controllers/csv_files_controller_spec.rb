# frozen_string_literal: true
require 'rails_helper'
require 'support/controller_macros'
require 'support/devise'
require 'controllers/shared_examples/shared_examples_for_authentication'
require 'controllers/shared_examples/shared_examples_for_alertable'

RSpec.describe CsvFilesController, type: :controller do
  it_behaves_like 'an authenticating controller', :index, 'csv_files'
  it_behaves_like 'an alertable controller'

  describe 'GET #index' do
    login_user

    before(:each) do
      create_list :csv_file, 3

      get :index
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end
  end
end
