require 'rails_helper'

require 'support/controller_macros'
require 'support/devise'
require 'support/shared_examples_for_authentication'

RSpec.describe DashboardsController, type: :controller do
	it_behaves_like "an authenticating controller", :index, "dashboards"

  #############################################################################
  ## index
  #############################################################################
  describe "GET #index" do
    login_user

    before(:each) do
      get :index
    end

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it "populates an array of csv_types" do
      expect(assigns(:csv_types)).to eq(CsvFile.types)
    end
  end

  #############################################################################
  ## create
  #############################################################################
  describe "POST create" do
    login_user
    
    context "when all csv files are loaded" do
      before(:each) do
        CsvFile::STI.keys.each do |cs|
          cs = CsvStorage.create(csv_file_type: cs, data_store: "a")
        end     
      end

      it "calls DataCsv.build_data_csv" do
        expect(DataCsv).to receive(:build_data_csv)
        post :create
      end 
    end

    context "when some csv files are missing" do
      it "does not call DataCsv.build_data_csv" do
        expect(DataCsv).not_to receive(:build_data_csv)
        post :create
      end 
    end
  end

  #############################################################################
  ## create
  #############################################################################
  describe "GET export" do
    login_user
    
    context "when all csv files are loaded" do
      before(:each) do
        CsvFile::STI.keys.each do |cs|
          cs = CsvStorage.create(csv_file_type: cs, data_store: "a")
        end     
      end

      it "calls DataCsv.to_csv" do
        expect(DataCsv).to receive(:to_csv)
        get :export, { format: :csv }
      end 
    end

    context "when some csv files are missing" do
      it "does not call DataCsv.to_csv" do
        expect(DataCsv).not_to receive(:to_csv)
        get :export, { format: :html }
      end 
    end
  end

  #############################################################################
  ## create
  #############################################################################
  describe "GET db_push" do
    login_user
    
    context "when all csv files are loaded" do
      before(:each) do
        CsvFile::STI.keys.each do |cs|
          cs = CsvStorage.create(csv_file_type: cs, data_store: "a")
        end     
      end

      it "calls DataCsv.to_gibct" do
        expect(DataCsv).to receive(:to_gibct)
        get :db_push
      end 
    end

    context "when some csv files are missing" do
      it "does not call DataCsv.to_gibct" do
        expect(DataCsv).not_to receive(:to_gibct)
        get :db_push
      end 
    end
  end
end
