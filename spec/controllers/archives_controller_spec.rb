# frozen_string_literal: true

require 'rails_helper'
require 'support/controller_macros'
require 'support/devise'
require 'controllers/shared_examples/shared_examples_for_authentication'

RSpec.describe ArchivesController, type: :controller do
  it_behaves_like 'an authenticating controller', :index, 'archives'

  describe 'GET #index' do
    login_user

    before do
      create_list :version, 3, :production

      get(:index)
    end

    it 'populates an array of uploads' do
      expect(assigns(:archive_versions).length).to eq(2)
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET export' do
    login_user

    before do
      create_list :version, 3, :production
    end

    it 'causes a CSV to be exported' do
      allow(InstitutionsArchive).to receive(:export_by_version)
      get(:export, params: { csv_type: InstitutionsArchive.name, number: 2, format: :csv })
      expect(InstitutionsArchive).to have_received(:export_by_version)
    end

    it 'includes filename parameter in content-disposition header' do
      csv_type = InstitutionsArchive.name
      number = 2
      filename = "#{csv_type}_version_#{number}.csv"
      get(:export, params: { csv_type: csv_type, number: number, format: :csv })
      expect(response.headers['Content-Disposition']).to include("filename=\"#{filename}\"")
    end

    it 'redirects to index on error' do
      expect(get(:export, params: { csv_type: 'BlahBlah', format: :csv, number: 2 })).to redirect_to(action: :index)
      expect(get(:export, params: { csv_type: 'Weam', format: :xml, number: 2 })).to redirect_to(action: :index)
    end
  end
end
