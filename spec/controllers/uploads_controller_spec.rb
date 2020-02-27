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

    def requirements(csv_class, requirement_class)
      csv_class.validators
               .find { |requirements| requirements.class == requirement_class }
    end

    def map_attributes(csv_class, requirement_class)
      requirements(csv_class, requirement_class)
        .attributes
        .map { |column| csv_class::CSV_CONVERTER_INFO.select { |_k, v| v[:column] == column }.keys.join(', ') }
    end

    describe 'requirements_messages for Weam' do
      before do
        get :new, params: { csv_type: Weam.name }
      end

      it 'returns validates presence messages' do
        validations_of_str = '|', ','
        message = { message: 'Valid column separators are:', value: validations_of_str }
        expect(assigns(:requirements)).to include(message)
      end

      it 'returns validates numericality messages' do
        validations_of_str = 'current academic year va bah rate'
        message = { message: 'These columns can only contain numeric values: ', value: [validations_of_str] }
        expect(assigns(:requirements)).to include(message)
      end

      it 'returns validates WeamsValidator messages' do
        validations_of_str = 'Facility codes should be unique'
        message = { message: 'Requirement Description:', value: [validations_of_str] }
        expect(assigns(:custom_batch_validator)).to include(message)
      end
    end

    describe 'requirements_messages for CalculatorConstant' do
      before do
        get :new, params: { csv_type: CalculatorConstant.name }
      end

      it 'returns validates uniqueness messages' do
        validations_of_str = map_attributes(CalculatorConstant, ActiveRecord::Validations::UniquenessValidator)
        message = { message: 'These columns should contain unique values: ', value: validations_of_str }
        expect(assigns(:requirements)).to include(message)
      end

      it 'returns validates presence messages' do
        validations_of_str = 'name', 'value'
        message = { message: 'These columns must have a value: ', value: validations_of_str }
        expect(assigns(:requirements)).to include(message)
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
                 upload: { upload_file: upload_file, skip_lines: 0, comment: 'Test', csv_type: 'Weam'  }
               }
        end.to change(Weam, :count).by(2)
      end

      it 'redirects to show' do
        expect(
          post(:create,
               params: {
                 upload: { upload_file: upload_file, skip_lines: 0, comment: 'Test', csv_type: 'Weam'  }
               })
        ).to redirect_to(action: :show, id: assigns(:upload).id)
      end

      it 'formats an notice message when some records do not validate' do
        file = build(:upload, csv_name: 'weam_invalid.csv').upload_file
        post(:create,
             params: {
               upload: { upload_file: file, skip_lines: 0, comment: 'Test', csv_type: 'Weam' }
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
                     upload_file: upload_file, skip_lines: 0, comment: 'Test', csv_type: 'Blah'
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
                   upload: { upload_file: nil, skip_lines: 0, comment: 'Test', csv_type: 'Weam' }
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
                 upload: { upload_file: file, skip_lines: 0, comment: 'Test', csv_type: 'Weam' }
               })
        ).to redirect_to(action: :show, id: assigns(:upload).id)
      end

      it 'formats a notice message in the flash' do
        file = build(:upload, csv_name: 'weam_missing_column.csv').upload_file
        post(:create,
             params: { upload: { upload_file: file, skip_lines: 0, comment: 'Test', csv_type: 'Weam' } })

        message = flash[:alert]['The following headers should be checked: '].try(:first)
        expect(message).to match(/Independent study is a missing header/)
      end
    end

    context 'with a csv file with invalid delimiters' do
      it 'formats a notice message in the flash' do
        file = build(:upload, csv_name: 'weam_caret_col_sep.csv').upload_file
        expect(
          post(:create,
               params: { upload: { upload_file: file, skip_lines: 0, comment: 'Test', csv_type: 'Weam' } })
        ).to render_template(:new)
        error_message = 'Unable to determine column separator. "|" and ","'
        expect(flash.alert).to include(error_message)
      end
    end

    context 'when specifying SchoolCertifyingOfficial csv_type' do
      it 'Uploads a SchoolCertifyingOfficial file' do
        file = build(:upload, csv_name: 'school_certifying_official.csv').upload_file
        expect do
          post(:create,
               params: {
                 upload: { upload_file: file, skip_lines: 0, comment: 'Test', csv_type: 'SchoolCertifyingOfficial' }
               })
        end.to change(SchoolCertifyingOfficial, :count).by(2)
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
