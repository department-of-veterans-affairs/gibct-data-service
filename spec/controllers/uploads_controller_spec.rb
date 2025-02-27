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

      it 'assigns extensions' do
        expect(assigns(:extensions)).to include('.xls', '.xlsx', '.csv', '.txt')
      end
    end

    context 'when specifying an invalid csv_type' do
      it 'redirects to the dashboard' do
        expect(get(:new, params: { csv_type: 'FexumGibberit' })).to redirect_to('/dashboards')
      end

      it 'formats an error message in the flash' do
        get :new, params: { csv_type: 'FexumGibberit' }

        expect(flash[:danger]).to be_present
        expect(flash[:danger]).to match('Csv type FexumGibberit is not a valid CSV data source')
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

        expect(flash[:danger]).to be_present
        expect(flash[:danger]).to match('Csv type cannot be blank.')
      end
    end

    def requirements(csv_class, requirement_class)
      csv_class.validators
               .find { |requirements| requirements.instance_of?(requirement_class) }
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
        validations_of_str = ['facility code', 'institution name', 'institution country']
        message = { message: 'These columns must have a value: ', value: validations_of_str }
        expect(assigns(:requirements)).to include(message)
      end

      it 'returns validates WeamsValidator messages' do
        message = 'Facility codes should be unique'
        # message = { message: 'Requirement Description:', value: [validations_of_str] }
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
                 upload: { upload_file: upload_file, skip_lines: 0, comment: 'Test', csv_type: 'Weam' }
               }
        end.to change(Weam, :count).by(2)
      end

      it 'sets multiple_files on the Upload row to false when not checked on the form' do
        post :create,
             params: { upload: { upload_file: upload_file, skip_lines: 0, comment: 'Test', csv_type: 'Weam' } }
        # some goofiness with the column name multiple_files
        expect(Upload.where(multiple_file_upload: true).last).to be nil
      end

      it 'sets multiple_file_upload on the Upload row to true when checked on the form' do
        post :create,
             params: {
               upload: {
                 upload_file: upload_file,
                 skip_lines: 0,
                 comment: 'Test',
                 csv_type: 'Weam',
                 multiple_file_upload: 'true'
               }
             }
        # some goofiness with the column name multiple_files
        expect(Upload.where(multiple_file_upload: true).last).not_to be nil
      end

      it 'redirects to show' do
        expect(
          post(:create,
               params: {
                 upload: { upload_file: upload_file, skip_lines: 0, comment: 'Test', csv_type: 'Weam' }
               })
        ).to redirect_to(action: :show, id: assigns(:upload).id)
      end

      it 'formats an notice message when some records do not validate' do
        file = build(:upload, csv_name: 'weam_invalid.csv').upload_file
        post(:create,
             params: {
               upload: { upload_file: file, skip_lines: 0, comment: 'Test', csv_type: 'Weam' }
             })
        expect(flash[:warning].key?(:'The following rows should be checked: ')).to be true
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

        message = flash[:warning][:'The following headers should be checked: '].try(:first)
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
        error_message = 'Unable to determine column separators, valid separators equal "|" and ","'
        expect(flash[:danger]).to include(error_message)
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

  describe 'POST create_async' do
    login_user

    subject(:create_async_upload) { post :create_async, params: upload_params }

    let(:upload_file) { build(:upload).upload_file }
    let!(:upload_content) { upload_file.read }
    let(:upload_params) do
      {
        upload: { upload_file: upload_file,
                  skip_lines: 0,
                  comment: 'Test',
                  csv_type:,
                  metadata: }
      }
    end
    let(:csv_type) { 'Program' }
    let(:current) { '1' }
    let(:metadata) { { upload_id: upload&.id, count: { current:, total: '3' } } }

    def upload
      Upload.first
    end

    before { upload_file.rewind }

    context 'with valid form input' do
      context 'when first upload in a series of multiple requests' do
        it 'creates new upload record with queued_at value' do
          csv_type = upload_params[:upload][:csv_type]
          expect { create_async_upload }.to change(Upload.where(csv_type:), :count).by(1)
          expect(upload.queued_at).not_to be_nil
        end

        it 'changes upload#body from nil to upload content' do
          expect { create_async_upload }.to change { upload&.body }.from(nil).to(upload_content)
        end

        it 'doesn\'t queue ProcessUploadJob' do
          create_async_upload
          allow(ProcessUploadJob).to receive(:perform_later)
          expect(ProcessUploadJob).not_to have_received(:perform_later)
          expect(upload.status_message).to be_nil
        end
      end

      context 'when intermediate upload in a series of multiple requests' do
        let(:current) { '2' }

        before { create(:async_upload, :with_body) }

        it 'finds previous upload in series instead of creating new one' do
          allow(Upload).to receive(:find_by)
          expect { create_async_upload }.not_to change(Upload, :count)
          expect(Upload).to have_received(:find_by).with(id: upload.id.to_s)
        end

        it 'concats upload content with previous upload body' do
          expect { create_async_upload }.to change { upload.reload.body }.to(upload.body + upload_content)
        end

        it 'doesn\'t queue ProcessUploadJob' do
          create_async_upload
          allow(ProcessUploadJob).to receive(:perform_later)
          expect(ProcessUploadJob).not_to have_received(:perform_later)
          expect(upload.status_message).to be_nil
        end
      end

      context 'when last upload in a series of multiple requests' do
        let(:current) { '3' }

        before { create(:async_upload, :with_body) }

        it 'finds previous upload in series instead of creating new one' do
          allow(Upload).to receive(:find_by)
          expect { create_async_upload }.not_to change(Upload, :count)
          expect(Upload).to have_received(:find_by).with(id: upload.id.to_s)
        end

        it 'concats upload content with previous upload body' do
          expect { create_async_upload }.to change { upload.reload.body }.to(upload.body + upload_content)
        end

        it 'queues ProcessUploadJob' do
          allow(ProcessUploadJob).to receive(:perform_later)
          expect { create_async_upload }.to change { upload.reload.status_message }.from(nil).to('queued for upload')
          expect(ProcessUploadJob).to have_received(:perform_later)
        end
      end

      context 'when body concatenation fails' do
        let(:current) { '2' }

        let!(:upload) { create(:async_upload, :with_body) }

        it 'cancels the existing upload' do
          allow(Upload).to receive(:find_by).with(id: upload.id.to_s).and_return(upload)
          allow(upload).to receive(:cancel!)
          allow(upload).to receive(:create_or_concat_body).and_raise(StandardError)
          create_async_upload
          expect(upload).to have_received(:cancel!)
          expect(response).to have_http_status(:internal_server_error)
        end
      end
    end
  end

  describe 'PATCH cancel' do
    login_user

    subject(:cancel_async_upload) { patch :cancel_async, params: { id: upload.id } }

    context 'when upload active' do
      let(:upload) { create(:async_upload, :with_body, status_message: 'importing records: 50% . . .') }

      it 'finds upload by upload id' do
        allow(Upload).to receive(:find_by)
        cancel_async_upload
        expect(Upload).to have_received(:find_by).with(id: upload.id.to_s)
      end

      it 'cancels upload' do
        allow(Upload).to receive(:find_by).with(id: upload.id.to_s).and_return(upload)
        expect { cancel_async_upload }.to change(upload, :canceled_at).from(nil)
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['canceled']).to be true
      end
    end

    context 'when upload inactive' do
      let(:upload) { create(:async_upload, :valid_upload) }

      it 'finds upload by upload id' do
        allow(Upload).to receive(:find_by)
        cancel_async_upload
        expect(Upload).to have_received(:find_by).with(id: upload.id.to_s)
      end

      it 'fails to cancel upload' do
        allow(Upload).to receive(:find_by).with(id: upload.id.to_s).and_return(upload)
        expect { cancel_async_upload }.not_to change { upload.reload.canceled_at }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe 'GET async_status' do
    login_user

    subject(:get_async_status) { get :async_status, params: { id: upload.id } }

    context 'when upload active' do
      let(:upload) { create(:async_upload, :active, status_message: 'importing records: 50% . . .') }

      it 'finds upload by upload id' do
        allow(Upload).to receive(:find_by)
        get_async_status
        expect(Upload).to have_received(:find_by).with(id: upload.id.to_s)
      end

      it 'returns async status' do
        get_async_status
        expect(response).to have_http_status(:ok)
        expect(response).to match_response_schema('async_upload_status')
        status = JSON.parse(response.body)['async_status'].transform_keys(&:to_sym)
        expect(status).to include({ message: upload.status_message,
                                    active: true,
                                    ok: false,
                                    canceled: false,
                                    type: upload.csv_type })
      end
    end

    context 'when upload complete' do
      let(:upload) { create(:async_upload, :complete_with_alerts) }

      it 'finds upload by upload id' do
        allow(Upload).to receive(:find_by)
        get_async_status
        expect(Upload).to have_received(:find_by).with(id: upload.id.to_s)
      end

      it 'returns async status' do
        get_async_status
        expect(response).to have_http_status(:ok)
        expect(response).to match_response_schema('async_upload_status')
        status = JSON.parse(response.body)['async_status'].transform_keys(&:to_sym)
        expect(status).to include({ message: upload.status_message,
                                    active: false,
                                    ok: true,
                                    canceled: false,
                                    type: upload.csv_type })
      end

      it 'updates flash[:csv_success] and flash[:warning]' do
        get_async_status
        expect(flash[:csv_success]).to eq(upload.alerts[:csv_success])
        expect(flash[:warning]).to eq(upload.alerts[:warning])
      end
    end

    context 'when error encountered' do
      let(:upload) { create(:async_upload, :complete_with_alerts) }

      it 'returns internal server error' do
        allow(Upload).to receive(:find_by).with(id: upload.id.to_s).and_return(upload)
        allow(upload).to receive(:alerts).and_raise(StandardError)
        get_async_status
        expect(response).to have_http_status(:internal_server_error)
      end
    end
  end
end
