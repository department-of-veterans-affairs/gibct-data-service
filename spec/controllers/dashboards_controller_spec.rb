# frozen_string_literal: true

require 'rails_helper'
require 'support/controller_macros'
require 'support/devise'
require 'controllers/shared_examples/shared_examples_for_authentication'

RSpec.describe DashboardsController, type: :controller do
  it_behaves_like 'an authenticating controller', :index, 'dashboards'

  def load_table(klass)
    csv_name = "#{klass.name.underscore}.csv"
    csv_type = klass.name
    csv_path = 'spec/fixtures'

    upload = create :upload, csv_type: csv_type, csv_name: csv_name, user: User.first
    load_options = Common::Shared.file_type_defaults(klass.name)

    roo_options = { liberal_parsing: load_options[:liberal_parsing],
                    sheets: [{ klass: klass, skip_lines: load_options[:skip_lines].try(:to_i) }] }

    klass.load_with_roo("#{csv_path}/#{csv_name}", roo_options)
    upload.update(ok: true)
  end

  describe 'GET #index' do
    login_user

    before do
      # 3 Weam upload records
      create_list :upload, 3
      Upload.all[1].update(ok: true)

      create_list :upload, 3, csv_name: 'crosswalk.csv', csv_type: 'Crosswalk'
      Upload.where(csv_type: 'Crosswalk')[1].update(ok: true)

      get(:index)
    end

    it 'populates an array of uploads' do
      expect(assigns(:uploads).length).to eq(UPLOAD_TYPES.length)
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #build' do
    login_user

    before do
      CSV_TYPES_ALL_TABLES_CLASSES.each do |klass|
        load_table(klass)
      end
    end

    it 'builds a new institutions table and returns the version when successful' do
      post(:build)

      expect(assigns(:version)).not_to be_nil
      expect(Institution.count).to be_positive
    end

    it 'does not change the institutions table when not successful' do
      allow(InstitutionBuilder).to receive(:add_crosswalk).and_raise(StandardError, 'BOOM!')
      post(:build)

      expect(assigns(:error_msg)).to eq('BOOM!')
      expect(Institution.count).to be_zero
    end
  end

  describe 'GET export' do
    login_user

    before do
      CSV_TYPES_ALL_TABLES_CLASSES.each do |klass|
        load_table(klass)
      end

      post(:build)
    end

    it 'causes a CSV to be exported' do
      allow(Weam).to receive(:export)
      get(:export, params: { csv_type: 'Weam', format: :csv })
      expect(Weam).to have_received(:export)
    end

    it 'causes a CSV to be exported' do
      allow(AccreditationInstituteCampus).to receive(:export)
      allow(AccreditationRecord).to receive(:export)
      allow(AccreditationAction).to receive(:export)

      get(:export, params: { csv_type: 'Accreditation', format: :csv })

      expect(AccreditationInstituteCampus).to have_received(:export)
      expect(AccreditationRecord).to have_received(:export)
      expect(AccreditationAction).to have_received(:export)
    end

    it 'includes filename parameter in content-disposition header' do
      get(:export, params: { csv_type: 'Sva', format: :csv })
      expect(response.headers['Content-Disposition']).to include('filename="Sva.csv"')
    end

    it 'redirects to index on error' do
      expect(get(:export, params: { csv_type: 'BlahBlah', format: :csv })).to redirect_to(action: :index)
      expect(get(:export, params: { csv_type: 'Weam', format: :xml })).to redirect_to(action: :index)
    end
  end

  describe 'GET export_version' do
    login_user

    before do
      CSV_TYPES_ALL_TABLES_CLASSES.each do |klass|
        load_table(klass)
      end

      post(:build)
    end

    it 'causes a CSV to be exported' do
      allow(Institution).to receive(:export_by_version)
      get(:export_version, params: { format: :csv, number: 1 })
      expect(Institution).to have_received(:export_by_version)
    end

    it 'includes filename parameter in content-disposition header' do
      get(:export_version, params: { format: :csv, number: 1 })
      expect(response.headers['Content-Disposition']).to include('filename="institutions_version_1.csv"')
    end

    it 'redirects to index on error' do
      expect(get(:export_version, params: { format: :xml, number: 1 })).to redirect_to(action: :index)
    end
  end

  describe 'GET push' do
    before do
      allow(Archiver).to receive(:archive_previous_versions).and_return(nil)
    end

    login_user

    context 'with no existing preview records' do
      it 'returns an error message' do
        post(:push)
        expect(flash.alert).to eq('No preview version available')
        expect(Version.current_production).to be_blank
      end
    end

    describe 'with existing preview records' do
      before do
        create :version
      end

      context 'when successful' do
        it 'sets the new production version' do
          SiteMapperHelper.silence do
            current_preview = Version.current_preview
            expect(Version.current_production).to eq(nil)
            post(:push)
            expect(Version.current_production.production).to eq(true)
            expect(Version.current_production).to eq(current_preview)
          end
        end

        it 'updates production data' do
          SiteMapperHelper.silence do
            post(:push)
          end
          expect(flash.notice).to eq('Production data updated')
        end
      end
    end
  end

  describe 'GET api_fetch' do
    login_user

    it 'causes populate to be called for a CSV' do
      allow(Scorecard).to receive(:populate)
      get(:api_fetch, params: { csv_type: Scorecard.name })
      expect(Scorecard).to have_received(:populate)
    end

    it 'displays no populate message for a CSV without it' do
      get(:api_fetch, params: { csv_type: CalculatorConstant.name })
      expect(flash.alert).to eq("#{CalculatorConstant.name} is not configured to fetch data from an api")
    end

    it 'displays default populate message for a CSV without POPULATE_SUCCESS_MESSAGE' do
      allow(Scorecard).to receive(:populate).and_return(true)
      stub_const('Scorecard::POPULATE_SUCCESS_MESSAGE', nil)

      get(:api_fetch, params: { csv_type: Scorecard.name })
      expect(flash.notice).to eq("#{Scorecard.name} finished fetching data from it's api")
    end

    it 'displays error message' do
      message = 'displays error message'
      allow(Scorecard).to receive(:populate).and_raise(StandardError, message)
      get(:api_fetch, params: { csv_type: Scorecard.name })
      expect(flash.alert).to include(message)
    end

    it 'displays already fetching alert' do
      message = "#{Scorecard.name} is already being fetched by another user"
      create :upload, :scorecard_in_progress
      get(:api_fetch, params: { csv_type: Scorecard.name })
      expect(flash.alert).to include(message)
    end
  end
end
