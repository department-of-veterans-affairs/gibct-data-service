# frozen_string_literal: true
require 'rails_helper'
require 'support/controller_macros'
require 'support/devise'
require 'controllers/shared_examples/shared_examples_for_authentication'

RSpec.describe DashboardsController, type: :controller do
  it_behaves_like 'an authenticating controller', :index, 'dashboards'

  def load_upload_records
    # 3 Weam upload records
    create_list :upload, 3
    Upload.all[1].update(ok: true)

    create_list :upload, 3, csv_name: 'crosswalk.csv', csv_type: 'Crosswalk'
    Upload.where(csv_type: 'Crosswalk')[1].update(ok: true)
  end

  describe 'GET #index' do
    login_user

    before(:each) do
      load_upload_records
      get :index
    end

    it 'populates an array of uploads' do
      max_weam = Upload.find_by(csv_type: 'Weam', ok: true)
      max_crosswalk = Upload.find_by(csv_type: 'Crosswalk', ok: true)

      expect(assigns(:uploads).length).to eq(2)
      expect(assigns(:uploads).where(csv_type: 'Weam').first).to eq(max_weam)
      expect(assigns(:uploads).where(csv_type: 'Crosswalk').first).to eq(max_crosswalk)
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end
  end
end
