require 'rails_helper'

require 'support/controller_macros'
require 'support/devise'
require 'support/shared_examples_for_authentication'

RSpec.describe HcmsController, type: :controller do
  it_behaves_like "an authenticating controller", :index, "hcms"

  #############################################################################
  ## index
  #############################################################################
  describe "GET index" do
    login_user

    before(:each) do
      create :hcm
      @hcm = Hcm.first

      get :index
    end

    it "populates an array of csvs" do
      expect(assigns(:hcms)).to include(@hcm)
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
      @hcm = create :hcm
    end

    context "with a valid id" do
      it "populates a csv_file" do
        get :show, id: @hcm.id
        expect(assigns(:hcm)).to eq(@hcm)
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

    it "assigns a blank hcm record" do
      expect(assigns(:hcm)).to be_a_new(Hcm)
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
        @hcm = attributes_for :hcm
      end

      it "creates an hcm entry" do
        expect{ post :create, hcm: @hcm }.to change(Hcm, :count).by(1)
        expect(Hcm.find_by(institution: @hcm[:institution].upcase)).not_to be_nil
      end 
    end

    context "having invalid form input" do
      context "with no ope" do
        before(:each) do
          @hcm = attributes_for :hcm, ope: nil
        end

        it "does not create a new csv file" do
          expect{ post :create, hcm: @hcm }.to change(Hcm, :count).by(0)
        end
      end   

      context "with no hcm_type" do
        before(:each) do
          @hcm = attributes_for :hcm, hcm_type: nil
        end

        it "does not create a new csv file" do
          expect{ post :create, hcm: @hcm }.to change(Hcm, :count).by(0)
        end
      end   

      context "with no hcm_reason" do
        before(:each) do
          @hcm = attributes_for :hcm, hcm_reason: nil
        end

        it "does not create a new csv file" do
          expect{ post :create, hcm: @hcm }.to change(Hcm, :count).by(0)
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
      @hcm = create :hcm
      get :edit, id: @hcm.id
    end

    context "with a valid id" do
      it "assigns an hcm record" do
        expect(assigns(:hcm)).to eq(@hcm)
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end
    end

    context "with an invalid id" do
      before(:each) do
        @hcm = create :hcm
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
        @hcm = create :hcm

        @hcm_attributes = @hcm.attributes
        @hcm_attributes.delete("id")
        @hcm_attributes.delete("updated_at")
        @hcm_attributes.delete("created_at")
        @hcm_attributes["institution"] += "x"
      end

      it "assigns the hcm record" do
        put :update, id: @hcm.id, hcm: @hcm_attributes
        expect(assigns(:hcm)).to eq(@hcm)
      end

      it "updates an hcm entry" do
        expect{ 
          put :update, id: @hcm.id, hcm: @hcm_attributes 
        }.to change(Hcm, :count).by(0)

        new_hcm = Hcm.find(@hcm.id)
        expect(new_hcm.institution).not_to eq(@hcm.institution)
        expect(new_hcm.updated_at).not_to eq(@hcm.created_at)
      end 
    end

    context "having invalid form input" do
      context "with an invalid id" do
        before(:each) do
          @hcm = create :hcm

          @hcm_attributes = @hcm.attributes

          @hcm_attributes.delete("id")
          @hcm_attributes.delete("updated_at")
          @hcm_attributes.delete("created_at")
        end

        it "with an invalid id it raises an error" do
          expect{ 
            put :update, id: 0, hcm: @hcm_attributes 
          }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context "with no ope" do
        before(:each) do
          @hcm = create :hcm

          @hcm_attributes = @hcm.attributes
          @hcm_attributes.delete("id")
          @hcm_attributes.delete("updated_at")
          @hcm_attributes.delete("created_at")
          @hcm_attributes["ope"] = nil
        end

        it "does not update a hcm entry" do
          put :update, id: @hcm.id, hcm: @hcm_attributes 

          new_hcm = Hcm.find(@hcm.id)
          expect(new_hcm.institution).to eq(@hcm.institution)
        end
      end   

      context "with no hcm_type" do
        before(:each) do
          @hcm = create :hcm

          @hcm_attributes = @hcm.attributes
          @hcm_attributes.delete("id")
          @hcm_attributes.delete("updated_at")
          @hcm_attributes.delete("created_at")
          @hcm_attributes["hcm_type"] = nil
        end

        it "does not update a hcm entry" do
          put :update, id: @hcm.id, hcm: @hcm_attributes 

          new_hcm = Hcm.find(@hcm.id)
          expect(new_hcm.institution).to eq(@hcm.institution)
        end
      end   

      context "with no hcm_reason" do
        before(:each) do
          @hcm = create :hcm

          @hcm_attributes = @hcm.attributes
          @hcm_attributes.delete("id")
          @hcm_attributes.delete("updated_at")
          @hcm_attributes.delete("created_at")
          @hcm_attributes["hcm_reason"] = nil
        end

        it "does not update a hcm entry" do
          put :update, id: @hcm.id, hcm: @hcm_attributes 

          new_hcm = Hcm.find(@hcm.id)
          expect(new_hcm.institution).to eq(@hcm.institution)
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
      @hcm = create :hcm
    end

    context "with a valid id" do
      it "deletes a csv_file" do
        delete :destroy, id: @hcm.id
        expect(assigns(:hcm)).to eq(@hcm)
      end

      it "deletes an hcm record" do
        expect{ delete :destroy, id: @hcm.id }.to change(Hcm, :count).by(-1)
      end
    end

    context "with an invalid id" do
      it "raises an error" do
        expect{ delete :destroy, id: 0 }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
