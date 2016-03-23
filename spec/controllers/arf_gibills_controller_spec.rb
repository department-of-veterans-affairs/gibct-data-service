require 'rails_helper'

require 'support/controller_macros'
require 'support/devise'
require 'support/shared_examples_for_authentication'

RSpec.describe ArfGibillsController, type: :controller do
  it_behaves_like "an authenticating controller", :index, "arf_gibills"

  #############################################################################
  ## index
  #############################################################################
  describe "GET index" do
    login_user

    before(:each) do
      create :arf_gibill
      @arf_gibill = ArfGibill.first

      get :index
    end

    it "populates an array of csvs" do
      expect(assigns(:arf_gibills)).to include(@arf_gibill)
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
      @arf_gibill = create :arf_gibill
    end

    context "with a valid id" do
      it "populates a csv_file" do
        get :show, id: @arf_gibill.id
        expect(assigns(:arf_gibill)).to eq(@arf_gibill)
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

    it "assigns a blank ARF record" do
      expect(assigns(:arf_gibill)).to be_a_new(ArfGibill)
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
        @arf_gibill = attributes_for :arf_gibill
      end

      it "creates a arf entry" do
        expect{ post :create, arf_gibill: @arf_gibill }.to change(ArfGibill, :count).by(1)
        expect(ArfGibill.find_by(facility_code: @arf_gibill[:facility_code])).not_to be_nil
      end 
    end

    context "having invalid form input" do
      context "with no institution name" do
        before(:each) do
          @arf_gibill = attributes_for :arf_gibill, institution: nil
          end

        it "does not create a new csv file" do
          expect{ post :create, arf_gibill: @arf_gibill }.to change(ArfGibill, :count).by(0)
        end
      end   
  
      context "with no facility code" do
        before(:each) do
          @arf_gibill = attributes_for :arf_gibill, facility_code: nil
          end

        it "does not create a new csv file" do
          expect{ post :create, arf_gibill: @arf_gibill }.to change(ArfGibill, :count).by(0)
        end
      end   

      context "with a duplicate facility code" do
        before(:each) do
          arf = create :arf_gibill
          @arf_gibill = attributes_for :arf_gibill, facility_code: arf.facility_code
          end

        it "does not create a new csv file" do
          expect{ post :create, arf_gibill: @arf_gibill }.to change(ArfGibill, :count).by(0)
        end
      end

      context "with no total count of students" do
        before(:each) do
          @arf_gibill = attributes_for :arf_gibill, total_count_of_students: nil
          end

        it "does not create a new csv file" do
          expect{ post :create, arf_gibill: @arf_gibill }.to change(ArfGibill, :count).by(0)
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
      @arf_gibill = create :arf_gibill
      get :edit, id: @arf_gibill.id
    end

    context "with a valid id" do
      it "assigns a arf_gibill record" do
        expect(assigns(:arf_gibill)).to eq(@arf_gibill)
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end
    end

    context "with an invalid id" do
      before(:each) do
        @arf_gibill = create :arf_gibill
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
        @arf_gibill = create :arf_gibill

        @arf_gibill_attributes = @arf_gibill.attributes
        @arf_gibill_attributes.delete("id")
        @arf_gibill_attributes.delete("updated_at")
        @arf_gibill_attributes.delete("created_at")
        @arf_gibill_attributes["institution"] += "x"
      end

      it "assigns the arf_gibill record" do
        put :update, id: @arf_gibill.id, arf_gibill: @arf_gibill_attributes
        expect(assigns(:arf_gibill)).to eq(@arf_gibill)
      end

      it "updates a arf_gibill entry" do
        expect{ 
          put :update, id: @arf_gibill.id, arf_gibill: @arf_gibill_attributes 
        }.to change(ArfGibill, :count).by(0)

        new_arf_gibill = ArfGibill.find(@arf_gibill.id)
        expect(new_arf_gibill.institution).not_to eq(@arf_gibill.institution)
        expect(new_arf_gibill.updated_at).not_to eq(@arf_gibill.created_at)
      end 
    end

    context "having invalid form input" do
      context "with an invalid id" do
        before(:each) do
          @arf_gibill = create :arf_gibill

          @arf_gibill_attributes = @arf_gibill.attributes

          @arf_gibill_attributes.delete("id")
          @arf_gibill_attributes.delete("updated_at")
          @arf_gibill_attributes.delete("created_at")
        end

        it "with an invalid id it raises an error" do
          expect{ 
            put :update, id: 0, arf_gibill: @arf_gibill_attributes 
          }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context "with no institution name" do
        before(:each) do
          @arf_gibill = create :arf_gibill

          @arf_gibill_attributes = @arf_gibill.attributes
          @arf_gibill_attributes.delete("id")
          @arf_gibill_attributes.delete("updated_at")
          @arf_gibill_attributes.delete("created_at")
          @arf_gibill_attributes["institution"] = nil
        end

        it "does not update a arf_gibill entry" do
          put :update, id: @arf_gibill.id, arf_gibill: @arf_gibill_attributes 

          new_arf_gibill = ArfGibill.find(@arf_gibill.id)
          expect(new_arf_gibill.institution).to eq(@arf_gibill.institution)
        end
      end   
  
      context "with no facility code" do
        before(:each) do
          @arf_gibill = create :arf_gibill

          @arf_gibill_attributes = @arf_gibill.attributes
          @arf_gibill_attributes.delete("id")
          @arf_gibill_attributes.delete("updated_at")
          @arf_gibill_attributes.delete("created_at")
          @arf_gibill_attributes["facility_code"] = nil
        end

        it "does not update a arf_gibill entry" do
          put :update, id: @arf_gibill.id, arf_gibill: @arf_gibill_attributes 

          new_arf_gibill = ArfGibill.find(@arf_gibill.id)
          expect(new_arf_gibill.facility_code).to eq(@arf_gibill.facility_code)
        end
      end 

      context "with a duplicate facility code" do
        before(:each) do
          @arf_gibill = create :arf_gibill
          @dup = create :arf_gibill

          @arf_gibill_attributes = @arf_gibill.attributes
          @arf_gibill_attributes.delete("id")
          @arf_gibill_attributes.delete("updated_at")
          @arf_gibill_attributes.delete("created_at")
          @arf_gibill_attributes["facility_code"] = @dup.facility_code
        end

        it "does not update a arf_gibill entry" do
          put :update, id: @arf_gibill.id, arf_gibill: @arf_gibill_attributes 

          new_arf_gibill = ArfGibill.find(@arf_gibill.id)
          expect(new_arf_gibill.facility_code).to eq(@arf_gibill.facility_code)
        end
      end  

      context "with no total count of students" do
        before(:each) do
          @arf_gibill = create :arf_gibill

          @arf_gibill_attributes = @arf_gibill.attributes
          @arf_gibill_attributes.delete("id")
          @arf_gibill_attributes.delete("updated_at")
          @arf_gibill_attributes.delete("created_at")
          @arf_gibill_attributes["total_count_of_students"] = nil
        end

        it "does not update a arf_gibill entry" do
          put :update, id: @arf_gibill.id, arf_gibill: @arf_gibill_attributes 

          new_arf_gibill = ArfGibill.find(@arf_gibill.id)
          expect(new_arf_gibill.facility_code).to eq(@arf_gibill.facility_code)
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
      @arf_gibill = create :arf_gibill
    end

    context "with a valid id" do
      it "assigns a csv_file" do
        delete :destroy, id: @arf_gibill.id
        expect(assigns(:arf_gibill)).to eq(@arf_gibill)
      end

      it "deletes a arf_gibills file record" do
        expect{ delete :destroy, id: @arf_gibill.id }.to change(ArfGibill, :count).by(-1)
      end
    end

    context "with an invalid id" do
      it "raises an error" do
        expect{ delete :destroy, id: 0 }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
