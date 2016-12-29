# frozen_string_literal: true
require 'rails_helper'
require 'support/controller_macros'
require 'support/devise'
require 'controllers/shared_examples/shared_examples_for_authentication'
require 'controllers/shared_examples/shared_examples_for_alertable'

RSpec.describe CsvFilesController, type: :controller do
  it_behaves_like 'an authenticating controller', :index, 'csv_files'
  it_behaves_like 'an alertable controller'

  describe 'GET #index' do
    login_user

    before(:each) do
      create :weam_csv_file
      get :index
    end

    it 'populates an array of csvs' do
      expect(assigns(:csv_files)).to include(CsvFile.first)
    end

    it 'renders the index template' do
      expect(response).to render_template(:index)
    end
  end

  describe 'GET show' do
    login_user

    context 'with a valid id' do
      let(:csv_file) { CsvFile.first }

      before(:each) do
        get :show, id: create(:weam_csv_file).id
      end

      it 'populates a csv_file' do
        expect(assigns(:csv_file)).to eq(csv_file)
      end

      it 'renders the show template' do
        expect(response).to render_template(:show)
      end
    end

    context 'with a invalid id' do
      it 'redirects to the index' do
        get :show, id: 0
        expect(response).to redirect_to(csv_files_path)
      end
    end
  end

  describe 'GET new' do
    login_user

    let(:default) { YAML.load_file('config/csv_file_defaults.yml')['Weam'] }

    before(:each) do
      get :new, csv_type: 'Weam'
    end

    it 'assigns a blank csv file record' do
      expect(assigns(:csv_file)).to be_a_new(CsvFile)
    end

    it 'assigns the csv type' do
      expect(assigns(:csv_file).csv_type).to eq('Weam')
    end

    it 'assigns the current user' do
      expect(assigns(:csv_file).user.email).to eq(controller.current_user.email)
    end

    it 'assigns defaults' do
      expect(assigns(:csv_file).skip_lines_before_header).to eq(default['skip_lines_before_header'])
      expect(assigns(:csv_file).skip_lines_after_header).to eq(default['skip_lines_after_header'])
      expect(assigns(:csv_file).delimiter).to eq(default['delimiter'])
    end
  end

  describe 'POST create' do
    login_user

    context 'with valid form input' do
      let(:facility_codes) { %w(00000146 10000008 10000013) }

      before(:each) do
        post :create, csv_file: attributes_for(:weam_csv_file)
      end

      # it 'repopulates the associated csv table' do
      #   expect(Weam.pluck(:facility_code)).to match_array(facility_codes)
      # end

      it 'Creates a csv_file record reflecting a successful upload' do
        expect(assigns(:csv_file).result).to eq('Successful')
      end

      it 'redirects to the show' do
        expect(response).to redirect_to(csv_file_path(CsvFile.first.id))
      end
    end

    context 'with invalid form input' do
      before(:each) do
        post :create, csv_file: attributes_for(:csv_file, csv_type: 'BlahBlah')
      end

      it 'redirects to the new' do
        expect(response).to redirect_to(new_csv_file_path(csv_type: 'BlahBlah'))
      end
    end
  end
end
