require 'rails_helper'

require 'support/controller_macros'
require 'support/devise'
require 'support/shared_examples_for_authentication'

RSpec.describe WeamsController, type: :controller do
  it_behaves_like "an authenticating controller", :index, "weams"

  #############################################################################
  ## index
  #############################################################################
  describe "GET index" do
    login_user

    before(:each) do
      create :weam
      @weam = Weam.first

      get :index
    end

    it "populates an array of csvs" do
      expect(assigns(:weams)).to include(@weam)
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
      @weam = create :weam
    end

    context "with a valid id" do
      it "populates a csv_file" do
        get :show, id: @weam.id
        expect(assigns(:weam)).to eq(@weam)
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

    it "assigns a blank weam record" do
      expect(assigns(:weam)).to be_a_new(Weam)
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
        @weam = attributes_for :weam
      end

      it "creates a weam entry" do
        expect{ post :create, weam: @weam }.to change(Weam, :count).by(1)
        expect(Weam.find_by(facility_code: @weam[:facility_code])).not_to be_nil
      end 
    end

    context "having invalid form input" do
      context "with no institution name" do
        before(:each) do
          @weam = attributes_for :weam, institution: nil
        end

        it "does not create a new csv file" do
          expect{ post :create, weam: @weam }.to change(Weam, :count).by(0)
        end
      end   
  
      context "with no facility code" do
        before(:each) do
          @weam = attributes_for :weam, facility_code: nil
        end

        it "does not create a new csv file" do
          expect{ post :create, weam: @weam }.to change(Weam, :count).by(0)
        end
      end   

      context "with a duplicate facility code" do
        before(:each) do
          w = create :weam
          @weam = attributes_for :weam, facility_code: w.facility_code
        end

        it "does not create a new csv file" do
          expect{ post :create, weam: @weam }.to change(Weam, :count).by(0)
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
      @weam = create :weam
      get :edit, id: @weam.id
    end

    context "with a valid id" do
      it "assigns a weam record" do
        expect(assigns(:weam)).to eq(@weam)
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end
    end

    context "with an invalid id" do
      before(:each) do
        @weam = create :weam
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
        @weam = create :weam

        @weam_attributes = @weam.attributes
        @weam_attributes.delete("id")
        @weam_attributes.delete("updated_at")
        @weam_attributes.delete("created_at")
        @weam_attributes["institution"] += "x"
      end

      it "assigns the weam record" do
        put :update, id: @weam.id, weam: @weam_attributes
        expect(assigns(:weam)).to eq(@weam)
      end

      it "updates a weam entry" do
        expect{ 
          put :update, id: @weam.id, weam: @weam_attributes 
        }.to change(Weam, :count).by(0)

        new_weam = Weam.find(@weam.id)
        expect(new_weam.institution).not_to eq(@weam.institution)
        expect(new_weam.updated_at).not_to eq(@weam.created_at)
      end 
    end

    context "having invalid form input" do
      context "with an invalid id" do
        before(:each) do
          @weam = create :weam

          @weam_attributes = @weam.attributes

          @weam_attributes.delete("id")
          @weam_attributes.delete("updated_at")
          @weam_attributes.delete("created_at")
        end

        it "with an invalid id it raises an error" do
          expect{ 
            put :update, id: 0, weam: @weam_attributes 
          }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context "with no institution name" do
        before(:each) do
          @weam = create :weam

          @weam_attributes = @weam.attributes
          @weam_attributes.delete("id")
          @weam_attributes.delete("updated_at")
          @weam_attributes.delete("created_at")
          @weam_attributes["institution"] = nil
        end

        it "does not update a weam entry" do
          put :update, id: @weam.id, weam: @weam_attributes 

          new_weam = Weam.find(@weam.id)
          expect(new_weam.institution).to eq(@weam.institution)
        end
      end   
  
      context "with no facility code" do
        before(:each) do
          @weam = create :weam

          @weam_attributes = @weam.attributes
          @weam_attributes.delete("id")
          @weam_attributes.delete("updated_at")
          @weam_attributes.delete("created_at")
          @weam_attributes["facility_code"] = nil
        end

        it "does not update a weam entry" do
          put :update, id: @weam.id, weam: @weam_attributes 

          new_weam = Weam.find(@weam.id)
          expect(new_weam.facility_code).to eq(@weam.facility_code)
        end
      end 

      context "with a duplicate facility code" do
        before(:each) do
          @weam = create :weam
          @dup = create :weam

          @weam_attributes = @weam.attributes
          @weam_attributes.delete("id")
          @weam_attributes.delete("updated_at")
          @weam_attributes.delete("created_at")
          @weam_attributes["facility_code"] = @dup.facility_code
        end

        it "does not update a weam entry" do
          put :update, id: @weam.id, weam: @weam_attributes 

          new_weam = Weam.find(@weam.id)
          expect(new_weam.facility_code).to eq(@weam.facility_code)
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
      @weam = create :weam
    end

    context "with a valid id" do
      it "assigns a csv_file" do
        delete :destroy, id: @weam.id
        expect(assigns(:weam)).to eq(@weam)
      end

      it "deletes a weams file record" do
        expect{ delete :destroy, id: @weam.id }.to change(Weam, :count).by(-1)
      end
    end

    context "with an invalid id" do
      it "raises an error" do
        expect{ delete :destroy, id: 0 }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
