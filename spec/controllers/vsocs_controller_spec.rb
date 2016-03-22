require 'rails_helper'

require 'support/controller_macros'
require 'support/devise'
require 'support/shared_examples_for_authentication'

RSpec.describe VsocsController, type: :controller do
  it_behaves_like "an authenticating controller", :index, "vsocs"

  #############################################################################
  ## index
  #############################################################################
  describe "GET index" do
    login_user

    before(:each) do
      create :vsoc
      @vsoc = Vsoc.first

      get :index
    end

    it "populates an array of csvs" do
      expect(assigns(:vsocs)).to include(@vsoc)
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
      @vsoc = create :vsoc
    end

    context "with a valid id" do
      it "populates a csv_file" do
        get :show, id: @vsoc.id
        expect(assigns(:vsoc)).to eq(@vsoc)
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

    it "assigns a blank veteran success record" do
      expect(assigns(:vsoc)).to be_a_new(Vsoc)
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
        @vsoc = attributes_for :vsoc
      end

      it "creates a veteran success entry" do
        expect{ post :create, vsoc: @vsoc }.to change(Vsoc, :count).by(1)
        expect(Vsoc.find_by(facility_code: @vsoc[:facility_code])).not_to be_nil
      end 
    end

    context "having invalid form input" do
      context "with no institution name" do
        before(:each) do
          @vsoc = attributes_for :vsoc, institution: nil
        end

        it "does not create a new csv file" do
          expect{ post :create, vsoc: @vsoc }.to change(Vsoc, :count).by(0)
        end
      end   
  
      context "with no facility code" do
        before(:each) do
          @vsoc = attributes_for :vsoc, facility_code: nil
          end

        it "does not create a new csv file" do
          expect{ post :create, vsoc: @vsoc }.to change(Vsoc, :count).by(0)
        end
      end   

      context "with a duplicate facility code" do
        before(:each) do
          vsoc = create :vsoc
          @vsoc = attributes_for :vsoc, facility_code: vsoc.facility_code
          end

        it "does not create a new csv file" do
          expect{ post :create, vsoc: @vsoc }.to change(Vsoc, :count).by(0)
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
      @vsoc = create :vsoc
      get :edit, id: @vsoc.id
    end

    context "with a valid id" do
      it "assigns a vsoc record" do
        expect(assigns(:vsoc)).to eq(@vsoc)
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end
    end

    context "with an invalid id" do
      before(:each) do
        @vsoc = create :vsoc
      end

      it "with an invalid id it raises an error" do
        expect{ get :edit, id: 0 }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  #############################################################################
  ## edit
  #############################################################################
  describe "PUT update" do
    login_user
    
    context "having valid form input" do
      before(:each) do
        @vsoc = create :vsoc

        @vsoc_attributes = @vsoc.attributes
        @vsoc_attributes.delete("id")
        @vsoc_attributes.delete("updated_at")
        @vsoc_attributes.delete("created_at")
        @vsoc_attributes["institution"] += "x"
      end

      it "assigns the vsoc record" do
        put :update, id: @vsoc.id, vsoc: @vsoc_attributes
        expect(assigns(:vsoc)).to eq(@vsoc)
      end

      it "updates a vsoc entry" do
        expect{ 
          put :update, id: @vsoc.id, vsoc: @vsoc_attributes 
        }.to change(Vsoc, :count).by(0)

        new_vsoc = Vsoc.find(@vsoc.id)
        expect(new_vsoc.institution).not_to eq(@vsoc.institution)
        expect(new_vsoc.updated_at).not_to eq(@vsoc.created_at)
      end 
    end

    context "having invalid form input" do
      context "with an invalid id" do
        before(:each) do
          @vsoc = create :vsoc

          @vsoc_attributes = @vsoc.attributes

          @vsoc_attributes.delete("id")
          @vsoc_attributes.delete("updated_at")
          @vsoc_attributes.delete("created_at")
        end

        it "with an invalid id it raises an error" do
          expect{ 
            put :update, id: 0, vsoc: @vsoc_attributes 
          }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context "with no institution name" do
        before(:each) do
          @vsoc = create :vsoc

          @vsoc_attributes = @vsoc.attributes
          @vsoc_attributes.delete("id")
          @vsoc_attributes.delete("updated_at")
          @vsoc_attributes.delete("created_at")
          @vsoc_attributes["institution"] = nil
        end

        it "does not update a vsoc entry" do
          put :update, id: @vsoc.id, vsoc: @vsoc_attributes 

          new_vsoc = Vsoc.find(@vsoc.id)
          expect(new_vsoc.institution).to eq(@vsoc.institution)
        end
      end   
  
      context "with no facility code" do
        before(:each) do
          @vsoc = create :vsoc

          @vsoc_attributes = @vsoc.attributes
          @vsoc_attributes.delete("id")
          @vsoc_attributes.delete("updated_at")
          @vsoc_attributes.delete("created_at")
          @vsoc_attributes["facility_code"] = nil
        end

        it "does not update a vsoc entry" do
          put :update, id: @vsoc.id, vsoc: @vsoc_attributes 

          new_vsoc = Vsoc.find(@vsoc.id)
          expect(new_vsoc.facility_code).to eq(@vsoc.facility_code)
        end
      end 

      context "with a duplicate facility code" do
        before(:each) do
          @vsoc = create :vsoc
          @dup = create :vsoc

          @vsoc_attributes = @vsoc.attributes
          @vsoc_attributes.delete("id")
          @vsoc_attributes.delete("updated_at")
          @vsoc_attributes.delete("created_at")
          @vsoc_attributes["facility_code"] = @dup.facility_code
        end

        it "does not update a vsoc entry" do
          put :update, id: @vsoc.id, vsoc: @vsoc_attributes 

          new_vsoc = Vsoc.find(@vsoc.id)
          expect(new_vsoc.facility_code).to eq(@vsoc.facility_code)
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
      @vsoc = create :vsoc
    end

    context "with a valid id" do
      it "assigns a csv_file" do
        delete :destroy, id: @vsoc.id
        expect(assigns(:vsoc)).to eq(@vsoc)
      end

      it "deletes a vsoc file record" do
        expect{ delete :destroy, id: @vsoc.id }.to change(Vsoc, :count).by(-1)
      end
    end

    context "with an invalid id" do
      it "raises an error" do
        expect{ delete :destroy, id: 0 }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
