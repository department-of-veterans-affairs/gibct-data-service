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

    before(:each) do
      # 3 Weam upload records
      create_list :upload, 3
      Upload.all[1].update(ok: true)

      create_list :upload, 3, csv_name: 'crosswalk.csv', csv_type: 'Crosswalk'
      Upload.where(csv_type: 'Crosswalk')[1].update(ok: true)

      get :index
    end

    it 'populates an array of uploads' do
      expect(assigns(:uploads).length).to eq(2)
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #build' do
    login_user

    before(:each) do
      defaults = YAML.load_file(Rails.root.join('config', 'csv_file_defaults.yml'))

      InstitutionBuilder::TABLES.each do |klass|
        load_table(klass, skip_lines: defaults[klass.name]['skip_lines'])
      end
    end

    it 'builds a new institutions table and returns the version when successful' do
      get :build

      expect(assigns(:version)).not_to be_nil
      expect(Institution.count).to be_positive
    end

    it 'does not change the institutions table when not successful' do
      allow(InstitutionBuilder).to receive(:add_crosswalk).and_raise(StandardError, 'BOOM!')
      get :build

      expect(assigns(:error_msg)).to eq('BOOM!')
      expect(Institution.count).to be_zero
    end
  end

  describe 'GET export' do
    login_user

    before(:each) do
      defaults = YAML.load_file(Rails.root.join('config', 'csv_file_defaults.yml'))

      InstitutionBuilder::TABLES.each do |klass|
        load_table(klass, skip_lines: defaults[klass.name]['skip_lines'])
      end

      get :build
    end

    it 'causes a CSV to be exported' do
      expect(Weam).to receive(:export)
      get :export, csv_type: 'Weam', format: :csv
    end

    it 'redirects to index on error' do
      expect(get(:export, csv_type: 'BlahBlah', format: :csv)).to redirect_to(action: :index)
      expect(get(:export, csv_type: 'Weam', format: :xml)).to redirect_to(action: :index)
    end
  end
end
