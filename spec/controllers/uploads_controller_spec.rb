# frozen_string_literal: true

require 'rails_helper'
require 'support/controller_macros'
require 'support/devise'
require 'controllers/shared_examples/shared_examples_for_authentication'

RSpec.describe UploadsController, type: :controller do
  it_behaves_like 'an authenticating controller', :index, 'uploads'

  describe 'GET index' do
    login_user

    before do
      create :upload
      get :index
    end

    it 'populates an array of uploads' do
      expect(assigns(:uploads)).to include(Upload.first)
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET new' do
    login_user

    context 'when specifying a csv_type' do
      before do
        get :new, params: { csv_type: 'Complaint' }
      end

      it 'assigns skip_lines for Complaint' do
        expect(assigns(:upload).skip_lines).to eq(7)
      end

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end
    end

    context 'when specifying an invalid csv_type' do
      it 'redirects to the dashboard' do
        expect(get(:new, params: { csv_type: 'FexumGibberit' })).to redirect_to('/dashboards')
      end

      it 'formats an error message in the flash' do
        get :new, params: { csv_type: 'FexumGibberit' }

        expect(flash[:alert]).to be_present
        expect(flash[:alert]).to match('Csv type FexumGibberit is not a valid CSV data source')
      end
    end

    context 'when specifying no csv_type' do
      it 'redirects to the dashboard' do
        expect(
          get(:new)
        ).to redirect_to('/dashboards')
      end

      it 'formats an error message in the flash' do
        get :new

        expect(flash[:alert]).to be_present
        expect(flash[:alert]).to match('Csv type cannot be blank.')
      end
    end

    context 'validators_messages for weams' do
      before do
        get :new, params: { csv_type: 'Weams' }
      end

      it 'returns validate uniqueness messages' do

      end

      it 'returns validate presence messages' do

      end

      it 'returns validate numericality messages' do

      end

      it 'returns validate inclusion messages' do

      end

      it 'returns validate WeamsValidator messages' do

      end
    end

    context 'validators_messages for calculator_constants' do
      before do
        get :new, params: { csv_type: 'CalculatorConstants' }
      end

      it 'returns validate uniqueness messages' do

      end

      it 'returns validate presence messages' do

      end
    end
  end

  describe 'POST create' do
    let(:upload_file) { build(:upload).upload_file }

    login_user

    context 'with having valid form input' do
      it 'Uploads a csv file' do
        expect do
          post :create,
               params: {
                 upload: { upload_file: upload_file, skip_lines: 0, comment: 'Test', csv_type: 'Weam', col_sep: ','  }
               }
        end.to change(Weam, :count).by(2)
      end

      it 'redirects to show' do
        expect(
          post(:create,
               params: {
                 upload: { upload_file: upload_file, skip_lines: 0, comment: 'Test', csv_type: 'Weam', col_sep: ','  }
               })
        ).to redirect_to(action: :show, id: assigns(:upload).id)
      end

      it 'formats an notice message when some records do not validate' do
        file = build(:upload, csv_name: 'weam_invalid.csv').upload_file
        post(:create,
             params: {
               upload: { upload_file: file, skip_lines: 0, comment: 'Test', csv_type: 'Weam', col_sep: ',' }
             })

        expect(flash[:alert]['The following rows should be checked: ']).to be_present
      end
    end

    context 'with invalid form input' do
      context 'with a non-valid csv_type' do
        it 'renders the new view' do
          expect(
            post(:create,
                 params: {
                   upload: {
                     upload_file: upload_file, skip_lines: 0, comment: 'Test', csv_type: 'Blah', col_sep: ','
                   }
                 })
          ).to render_template(:new)
        end
      end

      context 'with a nil upload file' do
        it 'renders the new view' do
          expect(
            post(:create,
                 params: {
                   upload: { upload_file: nil, skip_lines: 0, comment: 'Test', csv_type: 'Weam', col_sep: ',' }
                 })
          ).to render_template(:new)
        end
      end
    end

    context 'with a mal-formed csv file' do
      it 'renders the show view' do
        file = build(:upload, csv_name: 'weam_missing_column.csv').upload_file

        expect(
          post(:create,
               params: {
                 upload: { upload_file: file, skip_lines: 0, comment: 'Test', csv_type: 'Weam', col_sep: ',' }
               })
        ).to redirect_to(action: :show, id: assigns(:upload).id)
      end

      it 'formats a notice message in the flash' do
        file = build(:upload, csv_name: 'weam_missing_column.csv').upload_file
        post(:create,
             params: { upload: { upload_file: file, skip_lines: 0, comment: 'Test', csv_type: 'Weam', col_sep: ',' } })

        message = flash[:alert]['The following headers should be checked: '].try(:first)
        expect(message).to match(/Independent study is a missing header/)
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
        expect(get(:show, params: { id: 0 })).to redirect_to(action: :index)
      end
    end
  end
end
