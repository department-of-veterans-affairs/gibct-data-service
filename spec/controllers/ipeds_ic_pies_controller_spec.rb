require 'rails_helper'

require 'support/controller_macros'
require 'support/devise'
require 'support/shared_examples_for_authentication'

RSpec.describe IpedsIcPiesController, type: :controller do
  it_behaves_like "an authenticating controller", :index, "ipeds_ic_pies"

  #############################################################################
  ## index
  #############################################################################
  describe "GET index" do
    login_user

    before(:each) do
      create :ipeds_ic_py
      @ipeds_ic_py = IpedsIcPy.first

      get :index
    end

    it "populates an array of csvs" do
      expect(assigns(:ipeds_ic_pys)).to include(@ipeds_ic_py)
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
      @ipeds_ic_py = create :ipeds_ic_py
    end

    context "with a valid id" do
      it "populates a csv_file" do
        get :show, id: @ipeds_ic_py.id
        expect(assigns(:ipeds_ic_py)).to eq(@ipeds_ic_py)
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

    it "assigns a blank ipeds_ic_py record" do
      expect(assigns(:ipeds_ic_py)).to be_a_new(IpedsIcPy)
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
        @ipeds_ic_py = attributes_for :ipeds_ic_py
      end

      it "creates an ipeds_ic_py entry" do
        expect{ post :create, ipeds_ic_py: @ipeds_ic_py }.to change(IpedsIcPy, :count).by(1)
        expect(IpedsIcPy.find_by(cross: @ipeds_ic_py[:cross])).not_to be_nil
      end 
    end

    context "having invalid form input" do
      context "with no cross" do
        before(:each) do
          @ipeds_ic_py = attributes_for :ipeds_ic_py, cross: nil
        end

        it "does not create a new csv file" do
          expect{ post :create, ipeds_ic_py: @ipeds_ic_py }.to change(IpedsIcPy, :count).by(0)
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
      @ipeds_ic_py = create :ipeds_ic_py
      get :edit, id: @ipeds_ic_py.id
    end

    context "with a valid id" do
      it "assigns an ipeds_ic_py record" do
        expect(assigns(:ipeds_ic_py)).to eq(@ipeds_ic_py)
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end
    end

    context "with an invalid id" do
      before(:each) do
        @ipeds_ic_py = create :ipeds_ic_py
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
        @ipeds_ic_py = create :ipeds_ic_py

        @ipeds_ic_py_attributes = @ipeds_ic_py.attributes
        @ipeds_ic_py_attributes.delete("id")
        @ipeds_ic_py_attributes.delete("updated_at")
        @ipeds_ic_py_attributes.delete("created_at")
        @ipeds_ic_py_attributes["cross"] += "x"
      end

      it "assigns the ipeds_ic_py record" do
        put :update, id: @ipeds_ic_py.id, ipeds_ic_py: @ipeds_ic_py_attributes
        expect(assigns(:ipeds_ic_py)).to eq(@ipeds_ic_py)
      end

      it "updates an ipeds_ic_py entry" do
        expect{ 
          put :update, id: @ipeds_ic_py.id, ipeds_ic_py: @ipeds_ic_py_attributes 
        }.to change(IpedsIcPy, :count).by(0)

        new_ipeds_ic_py = IpedsIcPy.find(@ipeds_ic_py.id)
        expect(new_ipeds_ic_py.cross).not_to eq(@ipeds_ic_py.cross)
        expect(new_ipeds_ic_py.updated_at).not_to eq(@ipeds_ic_py.created_at)
      end 
    end

    context "having invalid form input" do
      context "with an invalid id" do
        before(:each) do
          @ipeds_ic_py = create :ipeds_ic_py

          @ipeds_ic_py_attributes = @ipeds_ic_py.attributes

          @ipeds_ic_py_attributes.delete("id")
          @ipeds_ic_py_attributes.delete("updated_at")
          @ipeds_ic_py_attributes.delete("created_at")
        end

        it "with an invalid id it raises an error" do
          expect{ 
            put :update, id: 0, ipeds_ic_py: @ipeds_ic_py_attributes 
          }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context "with no cross" do
        before(:each) do
          @ipeds_ic_py = create :ipeds_ic_py

          @ipeds_ic_py_attributes = @ipeds_ic_py.attributes
          @ipeds_ic_py_attributes.delete("id")
          @ipeds_ic_py_attributes.delete("updated_at")
          @ipeds_ic_py_attributes.delete("created_at")
          @ipeds_ic_py_attributes["cross"] = nil
        end

        it "does not update a ipeds_ic_py entry" do
          put :update, id: @ipeds_ic_py.id, ipeds_ic_py: @ipeds_ic_py_attributes 

          new_ipeds_ic = IpedsIcPy.find(@ipeds_ic_py.id)
          expect(new_ipeds_ic.cross).to eq(@ipeds_ic_py.cross)
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
      @ipeds_ic_py = create :ipeds_ic_py
    end

    context "with a valid id" do
      it "deletes a csv_file" do
        delete :destroy, id: @ipeds_ic_py.id
        expect(assigns(:ipeds_ic_py)).to eq(@ipeds_ic_py)
      end

      it "deletes an ipeds_ic_py record" do
        expect{ delete :destroy, id: @ipeds_ic_py.id }.to change(IpedsIcPy, :count).by(-1)
      end
    end

    context "with an invalid id" do
      it "raises an error" do
        expect{ delete :destroy, id: 0 }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
