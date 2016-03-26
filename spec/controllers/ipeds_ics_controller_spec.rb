require 'rails_helper'

require 'support/controller_macros'
require 'support/devise'
require 'support/shared_examples_for_authentication'

RSpec.describe IpedsIcsController, type: :controller do
  it_behaves_like "an authenticating controller", :index, "ipeds_ics"

  #############################################################################
  ## index
  #############################################################################
  describe "GET index" do
    login_user

    before(:each) do
      create :ipeds_ic
      @ipeds_ic = IpedsIc.first

      get :index
    end

    it "populates an array of csvs" do
      expect(assigns(:ipeds_ics)).to include(@ipeds_ic)
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
      @ipeds_ic = create :ipeds_ic
    end

    context "with a valid id" do
      it "populates a csv_file" do
        get :show, id: @ipeds_ic.id
        expect(assigns(:ipeds_ic)).to eq(@ipeds_ic)
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

    it "assigns a blank ipeds_ic record" do
      expect(assigns(:ipeds_ic)).to be_a_new(IpedsIc)
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
        @ipeds_ic = attributes_for :ipeds_ic
      end

      it "creates an ipeds_ic entry" do
        expect{ post :create, ipeds_ic: @ipeds_ic }.to change(IpedsIc, :count).by(1)
        expect(IpedsIc.find_by(cross: @ipeds_ic[:cross])).not_to be_nil
      end 
    end

    context "having invalid form input" do
      context "with no cross" do
        before(:each) do
          @ipeds_ic = attributes_for :ipeds_ic, cross: nil
        end

        it "does not create a new csv file" do
          expect{ post :create, ipeds_ic: @ipeds_ic }.to change(IpedsIc, :count).by(0)
        end
      end   
    end

    context "having invalid form input" do
      context "with no vet2" do
        before(:each) do
          @ipeds_ic = attributes_for :ipeds_ic, vet2: nil
        end

        it "does not create a new csv file" do
          expect{ post :create, ipeds_ic: @ipeds_ic }.to change(IpedsIc, :count).by(0)
        end
      end   
    end

    context "having invalid form input" do
      context "with no vet3" do
        before(:each) do
          @ipeds_ic = attributes_for :ipeds_ic, vet3: nil
        end

        it "does not create a new csv file" do
          expect{ post :create, ipeds_ic: @ipeds_ic }.to change(IpedsIc, :count).by(0)
        end
      end   
    end

    context "having invalid form input" do
      context "with no vet4" do
        before(:each) do
          @ipeds_ic = attributes_for :ipeds_ic, vet4: nil
        end

        it "does not create a new csv file" do
          expect{ post :create, ipeds_ic: @ipeds_ic }.to change(IpedsIc, :count).by(0)
        end
      end   
    end

    context "having invalid form input" do
      context "with no vet5" do
        before(:each) do
          @ipeds_ic = attributes_for :ipeds_ic, vet5: nil
        end

        it "does not create a new csv file" do
          expect{ post :create, ipeds_ic: @ipeds_ic }.to change(IpedsIc, :count).by(0)
        end
      end   
    end

    context "having invalid form input" do
      context "with no calsys" do
        before(:each) do
          @ipeds_ic = attributes_for :ipeds_ic, calsys: nil
        end

        it "does not create a new csv file" do
          expect{ post :create, ipeds_ic: @ipeds_ic }.to change(IpedsIc, :count).by(0)
        end
      end   
    end

    context "having invalid form input" do
      context "with no distnced" do
        before(:each) do
          @ipeds_ic = attributes_for :ipeds_ic, distnced: nil
        end

        it "does not create a new csv file" do
          expect{ post :create, ipeds_ic: @ipeds_ic }.to change(IpedsIc, :count).by(0)
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
      @ipeds_ic = create :ipeds_ic
      get :edit, id: @ipeds_ic.id
    end

    context "with a valid id" do
      it "assigns an ipeds_ic record" do
        expect(assigns(:ipeds_ic)).to eq(@ipeds_ic)
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end
    end

    context "with an invalid id" do
      before(:each) do
        @ipeds_ic = create :ipeds_ic
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
        @ipeds_ic = create :ipeds_ic

        @ipeds_ic_attributes = @ipeds_ic.attributes
        @ipeds_ic_attributes.delete("id")
        @ipeds_ic_attributes.delete("updated_at")
        @ipeds_ic_attributes.delete("created_at")
        @ipeds_ic_attributes["cross"] += "x"
      end

      it "assigns the ipeds_ic record" do
        put :update, id: @ipeds_ic.id, ipeds_ic: @ipeds_ic_attributes
        expect(assigns(:ipeds_ic)).to eq(@ipeds_ic)
      end

      it "updates an ipeds_ic entry" do
        expect{ 
          put :update, id: @ipeds_ic.id, ipeds_ic: @ipeds_ic_attributes 
        }.to change(IpedsIc, :count).by(0)

        new_ipeds_ic = IpedsIc.find(@ipeds_ic.id)
        expect(new_ipeds_ic.cross).not_to eq(@ipeds_ic.cross)
        expect(new_ipeds_ic.updated_at).not_to eq(@ipeds_ic.created_at)
      end 
    end

    context "having invalid form input" do
      context "with an invalid id" do
        before(:each) do
          @ipeds_ic = create :ipeds_ic

          @ipeds_ic_attributes = @ipeds_ic.attributes

          @ipeds_ic_attributes.delete("id")
          @ipeds_ic_attributes.delete("updated_at")
          @ipeds_ic_attributes.delete("created_at")
        end

        it "with an invalid id it raises an error" do
          expect{ 
            put :update, id: 0, ipeds_ic: @ipeds_ic_attributes 
          }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context "with no cross" do
        before(:each) do
          @ipeds_ic = create :ipeds_ic

          @ipeds_ic_attributes = @ipeds_ic.attributes
          @ipeds_ic_attributes.delete("id")
          @ipeds_ic_attributes.delete("updated_at")
          @ipeds_ic_attributes.delete("created_at")
          @ipeds_ic_attributes["cross"] = nil
        end

        it "does not update a ipeds_ic entry" do
          put :update, id: @ipeds_ic.id, ipeds_ic: @ipeds_ic_attributes 

          new_ipeds_ic = IpedsIc.find(@ipeds_ic.id)
          expect(new_ipeds_ic.cross).to eq(@ipeds_ic.cross)
        end
      end

      context "with no vet2" do
        before(:each) do
          @ipeds_ic = create :ipeds_ic

          @ipeds_ic_attributes = @ipeds_ic.attributes
          @ipeds_ic_attributes.delete("id")
          @ipeds_ic_attributes.delete("updated_at")
          @ipeds_ic_attributes.delete("created_at")
          @ipeds_ic_attributes["vet2"] = nil
        end

        it "does not update a ipeds_ic entry" do
          put :update, id: @ipeds_ic.id, ipeds_ic: @ipeds_ic_attributes 

          new_ipeds_ic = IpedsIc.find(@ipeds_ic.id)
          expect(new_ipeds_ic.cross).to eq(@ipeds_ic.cross)
        end
      end

      context "with no vet3" do
        before(:each) do
          @ipeds_ic = create :ipeds_ic

          @ipeds_ic_attributes = @ipeds_ic.attributes
          @ipeds_ic_attributes.delete("id")
          @ipeds_ic_attributes.delete("updated_at")
          @ipeds_ic_attributes.delete("created_at")
          @ipeds_ic_attributes["vet3"] = nil
        end

        it "does not update a ipeds_ic entry" do
          put :update, id: @ipeds_ic.id, ipeds_ic: @ipeds_ic_attributes 

          new_ipeds_ic = IpedsIc.find(@ipeds_ic.id)
          expect(new_ipeds_ic.cross).to eq(@ipeds_ic.cross)
        end
      end

      context "with no vet4" do
        before(:each) do
          @ipeds_ic = create :ipeds_ic

          @ipeds_ic_attributes = @ipeds_ic.attributes
          @ipeds_ic_attributes.delete("id")
          @ipeds_ic_attributes.delete("updated_at")
          @ipeds_ic_attributes.delete("created_at")
          @ipeds_ic_attributes["vet4"] = nil
        end

        it "does not update a ipeds_ic entry" do
          put :update, id: @ipeds_ic.id, ipeds_ic: @ipeds_ic_attributes 

          new_ipeds_ic = IpedsIc.find(@ipeds_ic.id)
          expect(new_ipeds_ic.cross).to eq(@ipeds_ic.cross)
        end
      end

      context "with no vet5" do
        before(:each) do
          @ipeds_ic = create :ipeds_ic

          @ipeds_ic_attributes = @ipeds_ic.attributes
          @ipeds_ic_attributes.delete("id")
          @ipeds_ic_attributes.delete("updated_at")
          @ipeds_ic_attributes.delete("created_at")
          @ipeds_ic_attributes["vet5"] = nil
        end

        it "does not update a ipeds_ic entry" do
          put :update, id: @ipeds_ic.id, ipeds_ic: @ipeds_ic_attributes 

          new_ipeds_ic = IpedsIc.find(@ipeds_ic.id)
          expect(new_ipeds_ic.cross).to eq(@ipeds_ic.cross)
        end
      end

      context "with no calsys" do
        before(:each) do
          @ipeds_ic = create :ipeds_ic

          @ipeds_ic_attributes = @ipeds_ic.attributes
          @ipeds_ic_attributes.delete("id")
          @ipeds_ic_attributes.delete("updated_at")
          @ipeds_ic_attributes.delete("created_at")
          @ipeds_ic_attributes["calsys"] = nil
        end

        it "does not update a ipeds_ic entry" do
          put :update, id: @ipeds_ic.id, ipeds_ic: @ipeds_ic_attributes 

          new_ipeds_ic = IpedsIc.find(@ipeds_ic.id)
          expect(new_ipeds_ic.cross).to eq(@ipeds_ic.cross)
        end
      end

      context "with no distnced" do
        before(:each) do
          @ipeds_ic = create :ipeds_ic

          @ipeds_ic_attributes = @ipeds_ic.attributes
          @ipeds_ic_attributes.delete("id")
          @ipeds_ic_attributes.delete("updated_at")
          @ipeds_ic_attributes.delete("created_at")
          @ipeds_ic_attributes["distnced"] = nil
        end

        it "does not update a ipeds_ic entry" do
          put :update, id: @ipeds_ic.id, ipeds_ic: @ipeds_ic_attributes 

          new_ipeds_ic = IpedsIc.find(@ipeds_ic.id)
          expect(new_ipeds_ic.cross).to eq(@ipeds_ic.cross)
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
      @ipeds_ic = create :ipeds_ic
    end

    context "with a valid id" do
      it "deletes a csv_file" do
        delete :destroy, id: @ipeds_ic.id
        expect(assigns(:ipeds_ic)).to eq(@ipeds_ic)
      end

      it "deletes an ipeds_ic record" do
        expect{ delete :destroy, id: @ipeds_ic.id }.to change(IpedsIc, :count).by(-1)
      end
    end

    context "with an invalid id" do
      it "raises an error" do
        expect{ delete :destroy, id: 0 }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
