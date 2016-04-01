require 'rails_helper'

require 'support/controller_macros'
require 'support/devise'
require 'support/shared_examples_for_authentication'

RSpec.describe DataCsvsController, type: :controller do
  it_behaves_like "an authenticating controller", :index, "data_csvs"

  #############################################################################
  ## index
  #############################################################################
  describe "GET index" do
    login_user

    before(:each) do
      create :data_csv
      @data_csv = DataCsv.first

      get :index
    end

    it "populates an array of csvs" do
      expect(assigns(:data_csvs)).to include(@data_csv)
    end

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end
  end

  #############################################################################
  ## show
  #############################################################################
  describe "GET show" do
    login_user

    before(:each) do
      @data_csv = create :data_csv
    end

    context "with a valid id" do
      it "populates a csv_file" do
        get :show, id: @data_csv.id
        expect(assigns(:data_csv)).to eq(@data_csv)
      end
    end

    context "with a invalid id" do
      it "raises an error" do
        expect{ get :show, id: 0 }.to raise_error(ActiveRecord::RecordNotFound)
      end
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

    it "assigns a blank eight key record" do
      expect(assigns(:data_csv)).to be_a_new(DataCsv)
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
        @data_csv = attributes_for :data_csv
      end

      it "creates a data_csv entry" do
        expect{ post :create, data_csv: @data_csv }.to change(DataCsv, :count).by(1)
        expect(DataCsv.find_by(facility_code: @data_csv[:facility_code])).not_to be_nil
      end 
    end

    context "having invalid form input" do
      context "with no institution name" do
        before(:each) do
          @data_csv = attributes_for :data_csv, institution: nil
        end

        it "does not create a new csv file" do
          expect{ post :create, data_csv: @data_csv }.to change(DataCsv, :count).by(0)
        end
      end   
  
      context "with no facility code" do
        before(:each) do
          @data_csv = attributes_for :data_csv, facility_code: nil
        end

        it "does not create a new csv file" do
          expect{ post :create, data_csv: @data_csv }.to change(DataCsv, :count).by(0)
        end
      end   

      context "with a duplicate facility code" do
        before(:each) do
          w = create :data_csv
          @data_csv = attributes_for :data_csv, facility_code: w.facility_code
        end

        it "does not create a new csv file" do
          expect{ post :create, data_csv: @data_csv }.to change(DataCsv, :count).by(0)
        end
      end   
    end
  end

  #############################################################################
  ## edit
  #############################################################################
  describe "GET edit" do
    login_user

    before(:each) do
      @data_csv = create :data_csv
      get :edit, id: @data_csv.id
    end

    context "with a valid id" do
      it "assigns a data_csv record" do
        expect(assigns(:data_csv)).to eq(@data_csv)
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end
    end

    context "with an invalid id" do
      before(:each) do
        @data_csv = create :data_csv
      end

      it "with an invalid id it raises an error" do
        expect{ get :edit, id: 0 }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  #############################################################################
  ## update
  #############################################################################
  describe "PUT update" do
    login_user
    
    context "having valid form input" do
      before(:each) do
        @data_csv = create :data_csv

        @data_csv_attributes = @data_csv.attributes
        @data_csv_attributes.delete("id")
        @data_csv_attributes.delete("updated_at")
        @data_csv_attributes.delete("created_at")
        @data_csv_attributes["institution"] += "x"
      end

      it "assigns the data_csv record" do
        put :update, id: @data_csv.id, data_csv: @data_csv_attributes
        expect(assigns(:data_csv)).to eq(@data_csv)
      end

      it "updates a data_csv entry" do
        expect{ 
          put :update, id: @data_csv.id, data_csv: @data_csv_attributes 
        }.to change(DataCsv, :count).by(0)

        new_data_csv = DataCsv.find(@data_csv.id)
        expect(new_data_csv.institution).not_to eq(@data_csv.institution)
        expect(new_data_csv.updated_at).not_to eq(@data_csv.created_at)
      end 
    end

    context "having invalid form input" do
      context "with an invalid id" do
        before(:each) do
          @data_csv = create :data_csv

          @data_csv_attributes = @data_csv.attributes

          @data_csv_attributes.delete("id")
          @data_csv_attributes.delete("updated_at")
          @data_csv_attributes.delete("created_at")
        end

        it "with an invalid id it raises an error" do
          expect{ 
            put :update, id: 0, data_csv: @data_csv_attributes 
          }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context "with no institution name" do
        before(:each) do
          @data_csv = create :data_csv

          @data_csv_attributes = @data_csv.attributes
          @data_csv_attributes.delete("id")
          @data_csv_attributes.delete("updated_at")
          @data_csv_attributes.delete("created_at")
          @data_csv_attributes["institution"] = nil
        end

        it "does not update a data_csv entry" do
          put :update, id: @data_csv.id, data_csv: @data_csv_attributes 

          new_data_csv = DataCsv.find(@data_csv.id)
          expect(new_data_csv.institution).to eq(@data_csv.institution)
        end
      end   
  
      context "with no facility code" do
        before(:each) do
          @data_csv = create :data_csv

          @data_csv_attributes = @data_csv.attributes
          @data_csv_attributes.delete("id")
          @data_csv_attributes.delete("updated_at")
          @data_csv_attributes.delete("created_at")
          @data_csv_attributes["facility_code"] = nil
        end

        it "does not update a data_csv entry" do
          put :update, id: @data_csv.id, data_csv: @data_csv_attributes 

          new_data_csv = DataCsv.find(@data_csv.id)
          expect(new_data_csv.facility_code).to eq(@data_csv.facility_code)
        end
      end 

      context "with a duplicate facility code" do
        before(:each) do
          @data_csv = create :data_csv
          @dup = create :data_csv

          @data_csv_attributes = @data_csv.attributes
          @data_csv_attributes.delete("id")
          @data_csv_attributes.delete("updated_at")
          @data_csv_attributes.delete("created_at")
          @data_csv_attributes["facility_code"] = @dup.facility_code
        end

        it "does not update a data_csv entry" do
          put :update, id: @data_csv.id, data_csv: @data_csv_attributes 

          new_data_csv = DataCsv.find(@data_csv.id)
          expect(new_data_csv.facility_code).to eq(@data_csv.facility_code)
        end
      end   
    end
  end

  #############################################################################
  ## destroy
  #############################################################################
  describe "DELETE destroy" do
    login_user

    before(:each) do
      @data_csv = create :data_csv
    end

    context "with a valid id" do
      it "assigns a csv_file" do
        delete :destroy, id: @data_csv.id
        expect(assigns(:data_csv)).to eq(@data_csv)
      end

      it "deletes a data_csvs file record" do
        expect{ delete :destroy, id: @data_csv.id }.to change(DataCsv, :count).by(-1)
      end
    end

    context "with an invalid id" do
      it "raises an error" do
        expect{ delete :destroy, id: 0 }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
