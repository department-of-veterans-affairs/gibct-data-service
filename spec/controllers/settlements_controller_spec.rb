require 'rails_helper'

require 'support/controller_macros'
require 'support/devise'
require 'support/shared_examples_for_authentication'

RSpec.describe SettlementsController, type: :controller do
  it_behaves_like "an authenticating controller", :index, "settlements"

  #############################################################################
  ## index
  #############################################################################
  describe "GET index" do
    login_user

    before(:each) do
      create :settlement
      @settlement = Settlement.first

      get :index
    end

    it "populates an array of csvs" do
      expect(assigns(:settlements)).to include(@settlement)
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
      @settlement = create :settlement
    end

    context "with a valid id" do
      it "populates a csv_file" do
        get :show, id: @settlement.id
        expect(assigns(:settlement)).to eq(@settlement)
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

    it "assigns a blank settlement record" do
      expect(assigns(:settlement)).to be_a_new(Settlement)
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
        @settlement = attributes_for :settlement
      end

      it "creates an settlement entry" do
        expect{ post :create, settlement: @settlement }.to change(Settlement, :count).by(1)
        expect(Settlement.find_by(institution: @settlement[:institution])).not_to be_nil
      end 
    end

    context "having invalid form input" do
      context "with no cross" do
        before(:each) do
          @settlement = attributes_for :settlement, cross: nil
          end

        it "does not create a new csv file" do
          expect{ post :create, settlement: @settlement }.to change(Settlement, :count).by(0)
        end
      end   
    end

    context "having invalid form input" do
      context "with no settlement description" do
        before(:each) do
          @settlement = attributes_for :settlement, settlement_description: nil
        end

        it "does not create a new csv file" do
          expect{ post :create, settlement: @settlement }.to change(Settlement, :count).by(0)
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
      @settlement = create :settlement
      get :edit, id: @settlement.id
    end

    context "with a valid id" do
      it "assigns an settlement record" do
        expect(assigns(:settlement)).to eq(@settlement)
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end
    end

    context "with an invalid id" do
      before(:each) do
        @settlement = create :settlement
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
        @settlement = create :settlement

        @settlement_attributes = @settlement.attributes
        @settlement_attributes.delete("id")
        @settlement_attributes.delete("updated_at")
        @settlement_attributes.delete("created_at")
        @settlement_attributes["institution"] += "x"
      end

      it "assigns the settlement record" do
        put :update, id: @settlement.id, settlement: @settlement_attributes
        expect(assigns(:settlement)).to eq(@settlement)
      end

      it "updates an settlement entry" do
        expect{ 
          put :update, id: @settlement.id, settlement: @settlement_attributes 
        }.to change(Settlement, :count).by(0)

        new_settlement = Settlement.find(@settlement.id)
        expect(new_settlement.institution).not_to eq(@settlement.institution)
        expect(new_settlement.updated_at).not_to eq(@settlement.created_at)
      end 
    end

    context "having invalid form input" do
      context "with an invalid id" do
        before(:each) do
          @settlement = create :settlement

          @settlement_attributes = @settlement.attributes

          @settlement_attributes.delete("id")
          @settlement_attributes.delete("updated_at")
          @settlement_attributes.delete("created_at")
        end

        it "with an invalid id it raises an error" do
          expect{ 
            put :update, id: 0, settlement: @settlement_attributes 
          }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context "with no cross" do
        before(:each) do
          @settlement = create :settlement

          @settlement_attributes = @settlement.attributes
          @settlement_attributes.delete("id")
          @settlement_attributes.delete("updated_at")
          @settlement_attributes.delete("created_at")
          @settlement_attributes["cross"] = nil
        end

        it "does not update a settlement entry" do
          put :update, id: @settlement.id, settlement: @settlement_attributes 

          new_settlement = Settlement.find(@settlement.id)
          expect(new_settlement.institution).to eq(@settlement.institution)
        end
      end   

      context "with no settlement description" do
        before(:each) do
          @settlement = create :settlement

          @settlement_attributes = @settlement.attributes
          @settlement_attributes.delete("id")
          @settlement_attributes.delete("updated_at")
          @settlement_attributes.delete("created_at")
          @settlement_attributes["settlement_description"] = nil
        end

        it "does not update a settlement entry" do
          put :update, id: @settlement.id, settlement: @settlement_attributes 

          new_settlement = Settlement.find(@settlement.id)
          expect(new_settlement.institution).to eq(@settlement.institution)
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
      @settlement = create :settlement
    end

    context "with a valid id" do
      it "deletes a csv_file" do
        delete :destroy, id: @settlement.id
        expect(assigns(:settlement)).to eq(@settlement)
      end

      it "deletes an settlement record" do
        expect{ delete :destroy, id: @settlement.id }.to change(Settlement, :count).by(-1)
      end
    end

    context "with an invalid id" do
      it "raises an error" do
        expect{ delete :destroy, id: 0 }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
