# frozen_string_literal: true

require 'rails_helper'
require 'support/controller_macros'
require 'support/devise'
require 'controllers/shared_examples/shared_examples_for_authentication'

RSpec.describe DashboardsController, type: :controller do
  before do
    allow(VetsApi::Service).to receive(:feature_enabled?).and_return(false)
  end

  it_behaves_like 'an authenticating controller', :index, 'dashboards'

  def load_table(klass)
    csv_name = "#{klass.name.underscore}.csv"
    csv_type = klass.name
    csv_path = 'spec/fixtures'

    upload = create :upload, csv_type: csv_type, csv_name: csv_name, user: User.first
    load_options = Common::Shared.file_type_defaults(klass.name)

    roo_options = { liberal_parsing: load_options[:liberal_parsing],
                    sheets: [{ klass: klass, skip_lines: load_options[:skip_lines].try(:to_i),
                               clean_rows: load_options[:clean_rows] }] }

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

    # Excludes CalculatorConstant
    it 'populates an array of uploads' do
      expect(assigns(:uploads).length).to eq(Upload.true_upload_types_all_names.length)
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST #build' do
    login_user

    before do
      CSV_TYPES_ALL_TABLES_CLASSES.each do |klass|
        load_table(klass)
      end
      create(:version, :production)
    end

    it 'Redirects to the dashboard' do
      post(:build)

      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to('/dashboards')
    end

    it 'Initiates a background job to generate the preview & geocode' do
      initial_progress_count = PreviewGenerationStatusInformation.count
      post(:build)
      expect(PreviewGenerationStatusInformation.count).to be > initial_progress_count
    end
  end

  describe 'POST unlock_generate_button' do
    login_user

    before do
      create(:version, :preview)
      create(:preview_generation_status_information)
    end

    it 'Clears the table related data and redirects to the dashboard' do
      expect(Version.count).to eq(1)
      expect(PreviewGenerationStatusInformation.count).to eq(1)
      post(:unlock_generate_button)
      expect(Version.count).to eq(0)
      expect(PreviewGenerationStatusInformation.count).to eq(0)
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to('/dashboards')
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

    it 'causes a Group to be exported' do
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

    it 'deconverts column names if required' do
      allow(Converters::OjtAppTypeConverter).to receive(:deconvert)

      get(:export, params: { csv_type: 'Program', format: :csv })

      expect(Converters::OjtAppTypeConverter).to have_received(:deconvert)
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
      expect(flash.notice).to eq("#{Scorecard.name} finished fetching data from its api")
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

    context 'when fetching files which do not require an api key' do
      before do
        system('cp spec/fixtures/Accreditation/download.zip tmp/download.zip')
        system('cp spec/fixtures/download_8_keys_sites.xls tmp/eight_key.xls')
      end

      # rubocop:disable RSpec/AnyInstance
      it 'downloads a zip file from the edu website' do
        allow_any_instance_of(NoKeyApis::NoKeyApiDownloader).to receive(:download_csv).and_return(true)

        get(:api_fetch, params: { csv_type: 'EightKey' })
        expect(Upload.last.ok).to be true
      end

      it 'extracts the content of the zip file' do
        allow_any_instance_of(NoKeyApis::NoKeyApiDownloader).to receive(:download_csv).and_return(true)

        get(:api_fetch, params: { csv_type: 'AccreditationAction' })

        expect(File.exist?('tmp/AccreditationActions.csv')).to be true
        expect(File.exist?('tmp/AccreditationRecords.csv')).to be true
        expect(File.exist?('tmp/InstitutionCampus.csv')).to be true
      end
      # rubocop:enable RSpec/AnyInstance
    end
  end

  describe 'GET #geocoding_issues' do
    login_user

    before do
      create(:version, :production, :with_ungecodable_foreign_institution, :with_geocoded_institution)
      get(:geocoding_issues)
    end

    it 'contains one ungeocodable institution' do
      expect(assigns(:ungeocodables).length).to eq(1)
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #accreditation_issues' do
    login_user

    before do
      create(:version, :production, :with_institution_accreditation_issue, :with_accredited_institution)
      # The institution(s) and accreditation_institute_campus records are
      # linked by ope & ope6 in the factories
      create(:accreditation_institute_campus)
      create(:accreditation_record)

      get(:accreditation_issues)
    end

    it 'contains one institution with an accreditation issue' do
      expect(assigns(:unaccrediteds).count).to eq(1)
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #export_ungeocodables' do
    login_user

    it 'causes a CSV to be exported' do
      allow(Institution).to receive(:export_ungeocodables)
      get(:export_ungeocodables, params: { format: :csv })
      expect(Institution).to have_received(:export_ungeocodables)
    end

    it 'includes filename parameter in content-disposition header' do
      get(:export_ungeocodables, params: { format: :csv })
      expect(response.headers['Content-Disposition']).to include('filename="ungeocodables.csv"')
    end

    it 'redirects to index on error' do
      expect(get(:export_ungeocodables, params: { format: :xml })).to redirect_to(action: :index)
    end
  end

  describe 'GET #export_unaccrediteds' do
    login_user

    before { create(:version, :production, :with_institution_accreditation_issue) }

    it 'causes a CSV to be exported' do
      allow(Institution).to receive(:export_unaccrediteds)
      get(:export_unaccrediteds, params: { format: :csv })
      expect(Institution).to have_received(:export_unaccrediteds)
    end

    it 'includes filename parameter in content-disposition header' do
      get(:export_unaccrediteds, params: { format: :csv })
      expect(response.headers['Content-Disposition']).to include('filename="unaccrediteds.csv"')
    end

    it 'redirects to index on error' do
      expect(get(:export_unaccrediteds, params: { format: :xml })).to redirect_to(action: :index)
    end
  end

  describe 'GET #export_orphans' do
    login_user

    it 'causes a CSV to be exported' do
      allow(CrosswalkIssue).to receive(:export_orphans)
      get(:export_orphans, params: { format: :csv })
      expect(CrosswalkIssue).to have_received(:export_orphans)
    end

    it 'includes filename parameter in content-disposition header' do
      get(:export_orphans, params: { format: :csv })
      expect(response.headers['Content-Disposition']).to include('filename="orphans.csv"')
    end

    it 'redirects to index on error' do
      expect(get(:export_orphans, params: { format: :xml })).to redirect_to(action: :index)
    end
  end

  describe 'GET #export_partials' do
    login_user

    it 'causes a CSV to be exported' do
      allow(CrosswalkIssue).to receive(:export_partials)
      get(:export_partials, params: { format: :csv })
      expect(CrosswalkIssue).to have_received(:export_partials)
    end

    it 'includes filename parameter in content-disposition header' do
      get(:export_partials, params: { format: :csv })
      expect(response.headers['Content-Disposition']).to include('filename="partials.csv"')
    end

    it 'redirects to index on error' do
      expect(get(:export_partials, params: { format: :xml })).to redirect_to(action: :index)
    end
  end

  describe 'GET #unlock_fetches' do
    login_user

    it 'redirects to the index page on completion' do
      expect(get(:unlock_fetches, params: { format: :html })).to redirect_to(action: :index)
    end

    it 'unlocks all fetches' do
      create(:upload, :failed_upload)
      expect(Upload.locked_fetches_exist?).to eq(true)
      get(:unlock_fetches, params: { format: :html })
      expect(Upload.locked_fetches_exist?).to eq(false)
      expect(flash[:notice]).to match(/All fetches have been unlocked/)
    end

    it 'flashes an error message if unlocking fails' do
      allow(Upload).to receive(:unlock_fetches).and_return(false)
      create(:upload, :failed_upload)
      expect(Upload.locked_fetches_exist?).to eq(true)
      get(:unlock_fetches, params: { format: :html })
      expect(Upload.locked_fetches_exist?).to eq(true)
      expect(flash[:alert]).to match(/Unlocking fetches failed/)
    end
  end
end
