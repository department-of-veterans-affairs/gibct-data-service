# frozen_string_literal: true

require 'rails_helper'
require 'support/controller_macros'
require 'support/devise'

RSpec.describe LatitudeLongitudeIssuesController, type: :controller do
  describe 'GET export' do
    login_user

    it 'causes a CSV to be exported' do
      allow(CensusLatLong).to receive(:export)
      get(:export)
      expect(CensusLatLong).to have_received(:export)
    end

    it 'includes filename parameter in content-disposition header' do
      allow(CensusLatLong).to receive(:export)
      get(:export)
      expect(response.headers['Content-Disposition']).to include('filename="CensusLatLong.zip"')
    end

    it 'displays error' do
      allow(CensusLatLong).to receive(:export).and_raise(StandardError, 'BOOM!')
      get(:export)
      expect(flash[:alert]).to be_present
      expect(flash[:alert]).to match 'BOOM!'
    end
  end

  describe 'GET new' do
    login_user

    context 'when specifying a csv_type' do
      before do
        get :new
      end

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'assigns extensions' do
        expect(assigns(:extensions)).to include('.xls', '.xlsx', '.csv', '.txt')
      end
    end

    def requirements(csv_class, requirement_class)
      csv_class.validators
               .find { |requirements| requirements.class == requirement_class }
    end

    def map_attributes(csv_class, requirement_class)
      requirements(csv_class, requirement_class)
        .attributes
        .map { |column| csv_class::CSV_CONVERTER_INFO.select { |_k, v| v[:column] == column }.keys.join(', ') }
    end

    describe 'requirements_messages for CensusLatLong' do
      before do
        get :new
      end

      it 'returns validates presence messages' do
        validations_of_str = '|', ','
        message = { message: 'Valid column separators are:', value: validations_of_str }
        expect(assigns(:requirements)).to include(message)
      end
    end
  end

  describe 'POST create' do
    let(:upload_file) { build(:upload, :census_lat_long).upload_file }

    login_user

    context 'with having valid form input' do
      it 'Uploads a csv file' do
        expect do
          post :create,
               params: {
                 upload: { upload_files: [upload_file], comment: 'Test', csv_type: CensusLatLong.name }
               }
        end.to change(CensusLatLong, :count).by(2)
      end

      it 'redirects to show' do
        expect(
          post(:create,
               params: {
                 upload: { upload_files: [upload_file], comment: 'Test', csv_type: CensusLatLong.name }
               })
        ).to redirect_to(action: :show, id: assigns(:upload).id)
      end
    end

    context 'with a csv file with invalid delimiters' do
      it 'formats a notice message in the flash' do
        file = build(:upload, :census_lat_long, csv_name: 'census_lat_long_caret.csv').upload_file
        expect(
          post(:create,
               params: { upload: { upload_files: [file], comment: 'Test', csv_type: CensusLatLong.name } })
        ).to render_template(:new)
        error_message = 'Unable to determine column separators, valid separators equal "|" and ","'
        expect(flash[:danger]).to include(error_message)
      end
    end
  end

  describe 'GET show' do
    login_user
    let(:upload) { create :upload }

    context 'with a valid id' do
      it 'gets the upload instance' do
        get :show, params: { id: upload.id }
        expect(assigns(:upload)).to eq(upload)
      end
    end

    context 'with a invalid id' do
      it 'renders the index view' do
        expect(get(:show, params: { id: 0 })).to redirect_to(uploads_path)
      end
    end
  end
end
