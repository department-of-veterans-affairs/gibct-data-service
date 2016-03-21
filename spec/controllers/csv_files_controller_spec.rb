require 'rails_helper'

require 'support/controller_macros'
require 'support/devise'
require 'support/shared_examples_for_authentication'

RSpec.describe CsvFilesController, type: :controller do
  #############################################################################
  ## generate_create_attributes
  ## Generates attributes used in create methods. Since we cannot use the 
  ## base CsvFile class, we use the WeamsCsvFile class.
  #############################################################################
  def generate_create_attributes(use_upload = true, factory = :weams_csv_file)

    csv = attributes_for factory
    csv[:type] = "WeamsCsvFile"

    if !use_upload
      csv[:upload] = nil 
    else
      csv[:upload].rewind
    end

    csv
  end

  #############################################################################
  ## Define constant WeamsCsvFile before any test.
  #############################################################################
  before(:all) do
    class WeamsCsvFile < CsvFile; end 
  end

  it_behaves_like "an authenticating controller", :index, "csv_files"

  #############################################################################
  ## index
  #############################################################################
  describe "GET index" do
    login_user

    before(:each) do
      create :weams_csv_file
      @csv = WeamsCsvFile.first

      get :index
    end

    it "populates an array of csvs" do
      expect(assigns(:csv_files)).to include(@csv)
    end

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end
  end

  #############################################################################
  ## new
  #############################################################################
  describe "GET new" do
    login_user

    before(:each) do
      get :new
    end

    it "assigns a blank weam record" do
      expect(assigns(:csv_file)).to be_a_new(CsvFile)
    end

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end
  end

  #############################################################################
  ## create
  #############################################################################
  describe "POST create" do
    login_user
    
    context "having valid form input" do
      before(:each) do
        @csv = generate_create_attributes
      end

      it "creates a csv file" do
        expect{ post :create, csv_file: @csv }.to change(WeamsCsvFile, :count).by(1)
      end 

      it "updates the data store" do
        old_data = CsvStorage.create(csv_file_type: "WeamsCsvFile").data_store
        post :create, csv_file: @csv
        new_data = CsvStorage.find_by(csv_file_type: "WeamsCsvFile").data_store
        expect(old_data).not_to eq(new_data)
      end

      it "updates the associated data table" do
        expect{ post :create, csv_file: @csv }.to change(Weam, :count).by(2)
        expect(Weam.find_by(facility_code: "00000146")).not_to be_blank
      end
    end

    context "having invalid form input" do
      context "with a non-valid csv_type" do
        before(:each) do
          @csv = generate_create_attributes
          @csv[:type] = "blah blah"
        end

        it "does not create a new csv file" do
          expect{ post :create, csv_file: @csv }.to change(CsvFile, :count).by(0)
        end

        it "does not update the data store" do
          old_data = CsvStorage.create(csv_file_type: "WeamsCsvFile").data_store
          post :create, csv_file: @csv
          new_data = CsvStorage.find_by(csv_file_type: "WeamsCsvFile").data_store
          expect(old_data).to eq(new_data)
        end

        it "does not update the associated data table" do
          expect{ post :create, csv_file: @csv }.to change(Weam, :count).by(0)
          expect(Weam.find_by(facility_code: "00000146")).to be_blank
        end
      end   
  
      context "with a nil upload file" do
        before(:each) do
          @csv = generate_create_attributes(false)
        end

        it "does not create a new csv file" do
          expect{ post :create, csv_file: @csv }.to change(CsvFile, :count).by(0)
        end

        it "does not update the data store" do
          old_data = CsvStorage.create(csv_file_type: "WeamsCsvFile").data_store
          post :create, csv_file: @csv
          new_data = CsvStorage.find_by(csv_file_type: "WeamsCsvFile").data_store
          expect(old_data).to eq(new_data)
        end

        it "does not update the associated data table" do
          expect{ post :create, csv_file: @csv }.to change(Weam, :count).by(0)
          expect(Weam.find_by(facility_code: "00000146")).to be_blank
        end
      end

      context "with a csv missing a header" do
        before(:each) do
          @csv = generate_create_attributes(false, :weams_csv_file_missing_header)
        end

        it "does not create a new csv file" do
          expect{ post :create, csv_file: @csv }.to change(CsvFile, :count).by(0)
        end

        it "does not update the data store" do
          old_data = CsvStorage.create(csv_file_type: "WeamsCsvFile").data_store
          post :create, csv_file: @csv
          new_data = CsvStorage.find_by(csv_file_type: "WeamsCsvFile").data_store
          expect(old_data).to eq(new_data)
        end

        it "does not update the associated data table" do
          expect{ post :create, csv_file: @csv }.to change(Weam, :count).by(0)
          expect(Weam.find_by(facility_code: "00000146")).to be_blank
        end
      end

      context "with a badly constructed csv" do
        before(:each) do
          @csv = generate_create_attributes(false, :weams_csv_file_duplicate_fac)
        end

        it "does not create a new csv file" do
          expect{ post :create, csv_file: @csv }.to change(CsvFile, :count).by(0)
        end

        it "does not update the data store" do
          old_data = CsvStorage.create(csv_file_type: "WeamsCsvFile").data_store
          post :create, csv_file: @csv
          new_data = CsvStorage.find_by(csv_file_type: "WeamsCsvFile").data_store
          expect(old_data).to eq(new_data)
        end

        it "does not update the associated data table" do
          expect{ post :create, csv_file: @csv }.to change(Weam, :count).by(0)
          expect(Weam.find_by(facility_code: "00000146")).to be_blank
        end
      end
    end
  end

  #############################################################################
  ## show
  #############################################################################
  describe "GET show" do
    login_user

    before(:each) do
      @csv = create :weams_csv_file
    end

    context "with a valid id" do
      it "populates a csv_file" do
        get :show, id: @csv.id
        expect(assigns(:csv_file)).to eq(@csv)
      end
    end

    context "with a invalid id" do
      it "raises an error" do
        expect{ get :show, id: 0 }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  #############################################################################
  ## destroy
  #############################################################################
  describe "DELETE destroy" do
    login_user

    before(:each) do
      @csv = create :weams_csv_file
    end

    context "with a valid id" do
      it "destroys a csv_file" do
        delete :destroy, id: @csv.id
        expect(assigns(:csv_file)).to eq(@csv)
      end

      it "deletes a raw file record" do
        expect{ delete :destroy, id: @csv.id }.to change(WeamsCsvFile, :count).by(-1)
      end
    end

    context "with an invalid id" do
      it "raises an error" do
        expect{ delete :destroy, id: 0 }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  #############################################################################
  ## send_csv_file
  #############################################################################
  describe "GET send_csv_file" do
    login_user

    before(:each) do
      post :create, csv_file: generate_create_attributes
      @csv = WeamsCsvFile.last
    end
    
    it "downloads a csv file" do
      get :send_csv_file, id: @csv.id 
      expect(response.header['Content-Type']).to eq('text/csv')     
    end
  end
end
