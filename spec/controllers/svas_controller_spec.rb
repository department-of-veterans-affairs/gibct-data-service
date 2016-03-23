require 'rails_helper'

require 'support/controller_macros'
require 'support/devise'
require 'support/shared_examples_for_authentication'

RSpec.describe SvasController, type: :controller do
  it_behaves_like "an authenticating controller", :index, "svas"

  #############################################################################
  ## index
  #############################################################################
  describe "GET index" do
    login_user

    before(:each) do
      create :sva
      @sva = Sva.first

      get :index
    end

    it "populates an array of csvs" do
      expect(assigns(:svas)).to include(@sva)
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
      @sva = create :sva
    end

    context "with a valid id" do
      it "populates a csv_file" do
        get :show, id: @sva.id
        expect(assigns(:sva)).to eq(@sva)
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

    it "assigns a blank sva record" do
      expect(assigns(:sva)).to be_a_new(Sva)
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
        @sva = attributes_for :sva
      end

      it "creates a sva entry" do
        expect{ post :create, sva: @sva }.to change(Sva, :count).by(1)
        expect(Sva.find_by(cross: @sva[:cross])).not_to be_nil
      end 
    end

    context "having invalid form input" do
      context "with no institution name" do
        before(:each) do
          @sva = attributes_for :sva, institution: nil
        end

        it "does not create a new csv file" do
          expect{ post :create, sva: @sva }.to change(Sva, :count).by(0)
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
      @sva = create :sva
      get :edit, id: @sva.id
    end

    context "with a valid id" do
      it "assigns a weam record" do
        expect(assigns(:sva)).to eq(@sva)
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end
    end

    context "with an invalid id" do
      before(:each) do
        @sva = create :sva
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
        @sva = create :sva

        @sva_attributes = @sva.attributes
        @sva_attributes.delete("id")
        @sva_attributes.delete("updated_at")
        @sva_attributes.delete("created_at")
        @sva_attributes["institution"] += "x"
      end

      it "assigns the sva record" do
        put :update, id: @sva.id, sva: @sva_attributes
        expect(assigns(:sva)).to eq(@sva)
      end

      it "updates a sva entry" do
        expect{ 
          put :update, id: @sva.id, sva: @sva_attributes 
        }.to change(Weam, :count).by(0)

        new_sva = Sva.find(@sva.id)
        expect(new_sva.institution).not_to eq(@sva.institution)
        expect(new_sva.updated_at).not_to eq(@sva.created_at)
      end 
    end

    context "having invalid form input" do
      context "with an invalid id" do
        before(:each) do
          @sva = create :sva

          @sva_attributes = @sva.attributes

          @sva_attributes.delete("id")
          @sva_attributes.delete("updated_at")
          @sva_attributes.delete("created_at")
        end

        it "with an invalid id it raises an error" do
          expect{ 
            put :update, id: 0, sva: @sva_attributes 
          }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context "with no institution name" do
        before(:each) do
          @sva = create :sva

          @sva_attributes = @sva.attributes
          @sva_attributes.delete("id")
          @sva_attributes.delete("updated_at")
          @sva_attributes.delete("created_at")
          @sva_attributes["institution"] = nil
        end

        it "does not update a sva entry" do
          put :update, id: @sva.id, sva: @sva_attributes 

          new_sva = Sva.find(@sva.id)
          expect(new_sva.institution).to eq(@sva.institution)
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
      @sva = create :sva
    end

    context "with a valid id" do
      it "assigns a csv_file" do
        delete :destroy, id: @sva.id
        expect(assigns(:sva)).to eq(@sva)
      end

      it "deletes a svas file record" do
        expect{ delete :destroy, id: @sva.id }.to change(Sva, :count).by(-1)
      end
    end

    context "with an invalid id" do
      it "raises an error" do
        expect{ delete :destroy, id: 0 }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
