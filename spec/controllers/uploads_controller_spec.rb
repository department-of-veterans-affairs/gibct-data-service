# frozen_string_literal: true

require 'rails_helper'
require 'support/controller_macros'
require 'support/devise'
require 'controllers/shared_examples/shared_examples_for_authentication'

RSpec.describe UploadsController, type: :controller do
  let(:klass) { Weam }

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
        get :new, params: { csv_type: klass.name }
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
    RSpec::Matchers.define_negated_matcher :not_change, :change

    let(:upload_file) { build(:upload).upload_file }
    let(:upload) { { upload_file:, skip_lines: 0, comment: 'Test', csv_type: klass.name } }
    let(:total) { '3' }
    let(:retries) { '5' }
    let(:multiple_file_upload) { true }
    let(:first_upload) { { **upload, sequence: { current: '1', total:, retries: } } }
    let(:second_upload) { { **upload, sequence: { current: '2', total:, retries: }, multiple_file_upload: } }
    let(:third_upload) { { **upload, sequence: { current: '3', total:, retries: }, multiple_file_upload: } }

    def load_sequence(*uploads)
      uploads.map do |upload|
        upload[:sequence].merge!(id: Upload.last.id.to_s) unless Upload.last.nil?
        post :create, params: { upload: }
      end
    end

    login_user

    context 'with having valid form input' do
      context 'when non-sequential' do
        it 'Uploads a csv file' do
          expect { post :create, params: { upload: } }.to change(klass, :count).by(2)
        end

        it 'sets multiple_files on the Upload row to false when not checked on the form' do
          post :create, params: { upload: }
          # some goofiness with the column name multiple_files
          expect(Upload.where(multiple_file_upload: true).last).to be nil
        end

        it 'sets multiple_file_upload on the Upload row to true when checked on the form' do
          post :create, params: { upload: { **upload, multiple_file_upload: true } }
          # some goofiness with the column name multiple_files
          expect(Upload.where(multiple_file_upload: true).last).not_to be nil
        end

        it 'redirects to show' do
          expect(post(:create, params: { upload: })).to redirect_to(action: :show, id: assigns(:upload).id)
        end

        it 'formats an notice message when some records do not validate' do
          upload[:upload_file] = build(:upload, csv_name: 'weam_invalid.csv').upload_file
          post :create, params: { upload: }
          expect(flash[:warning].key?(:'The following rows should be checked: ')).to be true
        end
      end

      context 'when first upload in sequence' do
        it 'Uploads a csv file and returns upload id' do
          expect { load_sequence(first_upload) }.to change(klass, :count).by(2)
          upload = JSON.parse(response.body)['upload']
          expect(upload['id']).to eq(Upload.last.id)
        end

        it 'does not update :ok or :completed_at column on upload' do
          load_sequence(first_upload)
          upload = Upload.find(JSON.parse(response.body)['upload']['id'])
          expect(upload.attributes).to include('ok' => false, 'completed_at' => nil)
        end

        it 'does not redirect to show' do
          expect(load_sequence(first_upload)).not_to redirect_to(action: :show, id: assigns(:upload).id)
        end

        it 'formats a success message' do
          load_sequence(first_upload)
          flash[:warning][:'The following rows should be checked: ']
          expect(flash[:csv_success].key?(:total_rows_count)).to be true
        end

        it 'formats an notice message when some records do not validate' do
          upload[:upload_file] = build(:upload, csv_name: 'weam_invalid.csv').upload_file
          load_sequence(first_upload)
          expect(flash[:warning].key?(:'The following rows should be checked: ')).to be true
        end
      end

      context 'when middle upload in sequence' do
        it 'uploads a csv file without creating new upload and returns existing upload id' do
          load_sequence(first_upload)
          expect { load_sequence(second_upload) }.to not_change(Upload, :count)
            .and change(klass, :count).by(2)
          body = JSON.parse(response.body)
          expect(body['upload']['id']).to eq(Upload.last.id)
        end

        it 'does not update :ok or :completed_at column on upload' do
          load_sequence(first_upload, second_upload)
          upload = Upload.find(JSON.parse(response.body)['upload']['id'])
          expect(upload.attributes).to include('ok' => false, 'completed_at' => nil)
        end

        it 'sets csv_row of importable record relative to the original upload file' do
          load_sequence(first_upload, second_upload)
          # expect consecutive integers for row numbers
          expect(klass.pluck(:csv_row)).to eq([*klass.first.csv_row..klass.count + 1])
        end

        it 'does not redirect to show' do
          load_sequence(first_upload)
          expect(load_sequence(second_upload)).not_to redirect_to(action: :show, id: assigns(:upload).id)
        end

        it 'concats success message onto existing success message' do
          load_sequence(first_upload)
          total = flash[:csv_success][:total_rows_count]
          new_total = (total.to_i * 2).to_s
          expect { load_sequence(second_upload) }.to change { flash[:csv_success][:total_rows_count] }
            .from(total).to(new_total)
        end

        it 'formats an notice message when some records do not validate' do
          upload[:upload_file] = build(:upload, csv_name: 'weam_invalid.csv').upload_file
          load_sequence(first_upload)
          warnings = flash[:warning][:'The following rows should be checked: '].length
          expect { load_sequence(second_upload) }
            .to change { flash[:warning][:'The following rows should be checked: '].length }.from(warnings).to(warnings * 2)
        end
      end

      context 'when last upload in sequence' do
        it 'uploads a csv file without creating new upload and returns existing upload id' do
          load_sequence(first_upload, second_upload)
          expect { load_sequence(third_upload) }.to not_change(Upload, :count)
            .and change(klass, :count).by(2)
          body = JSON.parse(response.body)
          expect(body['upload']['id']).to eq(Upload.last.id)
        end

        it 'updates :ok or :completed_at column on upload' do
          load_sequence(first_upload, second_upload, third_upload)
          upload = Upload.find(JSON.parse(response.body)['upload']['id'])
          expect(upload.ok).to be true
          expect(upload.completed_at).not_to be nil
        end

        it 'sets csv_row of importable record relative to the original upload file' do
          load_sequence(first_upload, second_upload, third_upload)
          # expect consecutive integers for row numbers
          expect(klass.pluck(:csv_row)).to eq([*klass.first.csv_row..klass.count + 1])
        end

        it 'does not redirect to show' do
          load_sequence(first_upload, second_upload)
          expect(load_sequence(third_upload)).not_to redirect_to(action: :show, id: assigns(:upload).id)
        end

        it 'concats success message onto existing success message' do
          load_sequence(first_upload, second_upload)
          total = flash[:csv_success][:total_rows_count]
          new_total = (total.to_i / 2 * 3).to_s
          expect { load_sequence(third_upload) }.to change { flash[:csv_success][:total_rows_count] }
            .from(total).to(new_total)
        end

        it 'formats an notice message when some records do not validate' do
          upload[:upload_file] = build(:upload, csv_name: 'weam_invalid.csv').upload_file
          load_sequence(first_upload, second_upload)
          warnings = flash[:warning][:'The following rows should be checked: '].length
          expect { load_sequence(third_upload) }.to change { flash[:warning][:'The following rows should be checked: '].length }
            .from(warnings).to(warnings / 2 * 3)
        end
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
                   upload: { upload_file: nil, skip_lines: 0, comment: 'Test', csv_type: klass.name }
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
                 upload: { upload_file: file, skip_lines: 0, comment: 'Test', csv_type: klass.name }
               })
        ).to redirect_to(action: :show, id: assigns(:upload).id)
      end

      it 'formats a notice message in the flash' do
        file = build(:upload, csv_name: 'weam_missing_column.csv').upload_file
        post(:create,
             params: { upload: { upload_file: file, skip_lines: 0, comment: 'Test', csv_type: klass.name } })

        message = flash[:warning][:'The following headers should be checked: '].try(:first)
        expect(message).to match(/Independent study is a missing header/)
      end
    end

    context 'with a csv file with invalid delimiters' do
      it 'formats a notice message in the flash' do
        file = build(:upload, csv_name: 'weam_caret_col_sep.csv').upload_file
        expect(
          post(:create,
               params: { upload: { upload_file: file, skip_lines: 0, comment: 'Test', csv_type: klass.name } })
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

    describe 'sequential retries' do
      before { load_sequence(first_upload, second_upload) }

      context 'when upload fails and retries available' do
        it 'does not rollback previous uploads' do
          upload[:upload_file] = nil
          load_sequence(third_upload)
          expect(klass.count.zero?).to be false
        end
      end

      context 'when upload fails and retries exhausted' do
        it 'rolls back previous uploads' do
          upload[:upload_file] = nil
          third_upload[:sequence][:retries] = 0
          load_sequence(third_upload)
          expect(klass.count.zero?).to be true
        end
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
