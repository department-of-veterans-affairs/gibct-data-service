require 'rails_helper'

require 'support/controller_macros'
require 'support/devise'
require 'support/shared_examples_for_authentication'

RSpec.describe ScorecardsController, type: :controller do
  it_behaves_like "an authenticating controller", :index, "scorecards"

  #############################################################################
  ## index
  #############################################################################
  describe "GET index" do
    login_user

    before(:each) do
      create :scorecard
      @scorecard = Scorecard.first

      get :index
    end

    it "populates an array of csvs" do
      expect(assigns(:scorecards)).to include(@scorecard)
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
      @scorecard = create :scorecard
    end

    context "with a valid id" do
      it "populates a csv_file" do
        get :show, id: @scorecard.id
        expect(assigns(:scorecard)).to eq(@scorecard)
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

    it "assigns a blank scorecard record" do
      expect(assigns(:scorecard)).to be_a_new(Scorecard)
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
        @scorecard = attributes_for :scorecard
      end

      it "creates an scorecard entry" do
        expect{ post :create, scorecard: @scorecard }.to change(Scorecard, :count).by(1)
        expect(Scorecard.find_by(institution: @scorecard[:institution])).not_to be_nil
      end 
    end

    context "having invalid form input" do
      context "with no ope" do
        before(:each) do
          @scorecard = attributes_for :scorecard, ope: nil
          end

        it "does not create a new csv file" do
          expect{ post :create, scorecard: @scorecard }.to change(Scorecard, :count).by(0)
        end
      end   

      context "with no ipeds" do
        before(:each) do
          @scorecard = attributes_for :scorecard, cross: nil
          end

        it "does not create a new csv file" do
          expect{ post :create, scorecard: @scorecard }.to change(Scorecard, :count).by(0)
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
      @scorecard = create :scorecard
      get :edit, id: @scorecard.id
    end

    context "with a valid id" do
      it "assigns an scorecard record" do
        expect(assigns(:scorecard)).to eq(@scorecard)
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end
    end

    context "with an invalid id" do
      before(:each) do
        @scorecard = create :scorecard
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
        @scorecard = create :scorecard

        @scorecard_attributes = @scorecard.attributes
        @scorecard_attributes.delete("id")
        @scorecard_attributes.delete("updated_at")
        @scorecard_attributes.delete("created_at")
        @scorecard_attributes["institution"] += "x"
      end

      it "assigns the scorecard record" do
        put :update, id: @scorecard.id, scorecard: @scorecard_attributes
        expect(assigns(:scorecard)).to eq(@scorecard)
      end

      it "updates an scorecard entry" do
        expect{ 
          put :update, id: @scorecard.id, scorecard: @scorecard_attributes 
        }.to change(Scorecard, :count).by(0)

        new_scorecard = Scorecard.find(@scorecard.id)
        expect(new_scorecard.institution).not_to eq(@scorecard.institution)
        expect(new_scorecard.updated_at).not_to eq(@scorecard.created_at)
      end 
    end

    context "having invalid form input" do
      context "with an invalid id" do
        before(:each) do
          @scorecard = create :scorecard

          @scorecard_attributes = @scorecard.attributes

          @scorecard_attributes.delete("id")
          @scorecard_attributes.delete("updated_at")
          @scorecard_attributes.delete("created_at")
        end

        it "with an invalid id it raises an error" do
          expect{ 
            put :update, id: 0, scorecard: @scorecard_attributes 
          }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context "with no ope id" do
        before(:each) do
          @scorecard = create :scorecard

          @scorecard_attributes = @scorecard.attributes
          @scorecard_attributes.delete("id")
          @scorecard_attributes.delete("updated_at")
          @scorecard_attributes.delete("created_at")
          @scorecard_attributes["ope"] = nil
        end

        it "does not update a scorecard entry" do
          put :update, id: @scorecard.id, scorecard: @scorecard_attributes 

          new_scorecard = Scorecard.find(@scorecard.id)
          expect(new_scorecard.ope).to eq(@scorecard.ope)
        end
      end 

      context "with no ipeds id" do
        before(:each) do
          @scorecard = create :scorecard

          @scorecard_attributes = @scorecard.attributes
          @scorecard_attributes.delete("id")
          @scorecard_attributes.delete("updated_at")
          @scorecard_attributes.delete("created_at")
          @scorecard_attributes["cross"] = nil
        end

        it "does not update a scorecard entry" do
          put :update, id: @scorecard.id, scorecard: @scorecard_attributes 

          new_scorecard = Scorecard.find(@scorecard.id)
          expect(new_scorecard.cross).to eq(@scorecard.cross)
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
      @scorecard = create :scorecard
    end

    context "with a valid id" do
      it "deletes a csv_file" do
        delete :destroy, id: @scorecard.id
        expect(assigns(:scorecard)).to eq(@scorecard)
      end

      it "deletes a scorecard record" do
        expect{ delete :destroy, id: @scorecard.id }.to change(Scorecard, :count).by(-1)
      end
    end

    context "with an invalid id" do
      it "raises an error" do
        expect{ delete :destroy, id: 0 }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
