require 'rails_helper'

require 'support/controller_macros'
require 'support/devise'
require 'support/shared_examples_for_authentication'

RSpec.describe CsvTypesController, type: :controller do
  it_behaves_like "an authenticating controller", :index, "csv_types"

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
  ## show
  #############################################################################
  describe "GET #show" do
    login_user

    let(:weams_csv_file_type) { CsvFile.types.last[1] }
    let(:weams_csv_file_type_humanized) { CsvFile.types.last[0] }

    before(:each) do
      @csv_files = create_list :weams_csv_file, 10
      get :show, id: weams_csv_file_type
    end

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it "assigns the csv_type parameter" do
      expect(assigns(:csv_type)).to eq(weams_csv_file_type)
    end

    it "assigns a humanized csv_type value" do
      expect(assigns(:humanized_csv_type)).to eq(weams_csv_file_type_humanized)
    end

    it "populates an array of csv files" do
      expect(assigns(:csv_files)).to eq(@csv_files)
    end

    it "gets the last uploaded csv file of that type" do
      last = WeamsCsvFile.order(:upload_date, :id).last
      expect(assigns(:last_csv)).to eq(last)
    end
  end
end
