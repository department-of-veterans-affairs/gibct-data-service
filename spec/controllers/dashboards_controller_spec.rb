# frozen_string_literal: true

require 'rails_helper'
require 'support/controller_macros'
require 'support/devise'
require 'controllers/shared_examples/shared_examples_for_authentication'

RSpec.describe DashboardsController, type: :controller do
  it_behaves_like 'an authenticating controller', :index, 'dashboards'

  def load_table(klass, options)
    csv_name = "#{klass.name.underscore}.csv"
    csv_type = klass.name
    csv_path = 'spec/fixtures'

    upload = create :upload, csv_type: csv_type, csv_name: csv_name, user: User.first
    klass.load("#{csv_path}/#{csv_name}", options)
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
      expect(assigns(:uploads).length).to eq(CSV_TYPES_ALL_TABLES.length)
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #build' do
    login_user

    before do
      defaults = YAML.load_file(Rails.root.join('config', 'csv_file_defaults.yml'))

      CSV_TYPES_ALL_TABLES.each do |klass|
        load_table(klass, skip_lines: defaults[klass.name]['skip_lines'])
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
      defaults = YAML.load_file(Rails.root.join('config', 'csv_file_defaults.yml'))

      CSV_TYPES_ALL_TABLES.each do |klass|
        load_table(klass, skip_lines: defaults[klass.name]['skip_lines'])
      end

      post(:build)
    end

    it 'causes a CSV to be exported' do
      allow(Weam).to receive(:export)
      get(:export, params: { csv_type: 'Weam', format: :csv })
      expect(Weam).to have_received(:export)
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
      defaults = YAML.load_file(Rails.root.join('config', 'csv_file_defaults.yml'))

      CSV_TYPES_ALL_TABLES.each do |klass|
        load_table(klass, skip_lines: defaults[klass.name]['skip_lines'])
      end

      post(:build)
    end

    it 'causes a CSV to be exported' do
      allow(Institution).to receive(:export_institutions_by_version)
      get(:export_version, params: { format: :csv, number: 1 })
      expect(Institution).to have_received(:export_institutions_by_version)
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
        before do
        end

        it 'adds a new version record' do
          SiteMapperHelper.silence do
            expect { post(:push) }.to change(Version, :count).by(1)
          end
        end

        it 'sets the new production version number to the preview number' do
          SiteMapperHelper.silence do
            post(:push)
          end

          expect(Version.current_production.number).to eq(Version.current_preview.number)
        end

        it 'updates production data' do
          SiteMapperHelper.silence do
            post(:push)
          end
          expect(flash.notice).to eq('Production data updated')
        end

        context 'and is not successful' do
          before do
            allow(Version).to receive(:create).and_return(Version.new)
          end

          it 'does not add a new version' do
            expect { post(:push) }.to change(Version, :count).by(0)
          end

          it 'returns an error message' do
            post(:push)
            expect(flash.alert).to eq('Production data not updated, remains at previous production version')
          end
        end
      end
    end
  end
end
