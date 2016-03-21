require 'rails_helper'

require 'support/controller_macros'
require 'support/devise'
require 'support/shared_examples_for_authentication'

RSpec.describe AccreditationsController, type: :controller do
  it_behaves_like "an authenticating controller", :index, "accreditations"

  #############################################################################
  ## index
  #############################################################################
  describe "GET index" do
    login_user

    before(:each) do
      create :accreditation
      @accreditation = Accreditation.first

      get :index
    end

    it "populates an array of csvs" do
      expect(assigns(:accreditations)).to include(@accreditation)
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
      @accreditation = create :accreditation
    end

    context "with a valid id" do
      it "populates a csv_file" do
        get :show, id: @accreditation.id
        expect(assigns(:accreditation)).to eq(@accreditation)
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
      expect(assigns(:accreditation)).to be_a_new(Accreditation)
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
        @accreditation = attributes_for :accreditation
      end

      it "creates an scorecard entry" do
        expect{ post :create, accreditation: @accreditation }.to change(Accreditation, :count).by(1)
        expect(Accreditation.find_by(institution_name: @accreditation[:institution_name])).not_to be_nil
      end 
    end

    context "having invalid form input" do
      context "with no agency_name" do
        before(:each) do
          @accreditation = attributes_for :accreditation, agency_name: nil
          end

        it "does not create a new csv file" do
          expect{ post :create, accreditation: @accreditation }.to change(Accreditation, :count).by(0)
        end
      end 

      context "with no csv_accreditation_type" do
        before(:each) do
          @accreditation = attributes_for :accreditation, csv_accreditation_type: nil
          end

        it "does not create a new csv file" do
          expect{ post :create, accreditation: @accreditation }.to change(Accreditation, :count).by(0)
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
      @accreditation = create :accreditation
      get :edit, id: @accreditation.id
    end

    context "with a valid id" do
      it "assigns an accreditation record" do
        expect(assigns(:accreditation)).to eq(@accreditation)
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end
    end

    context "with an invalid id" do
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
        @accreditation = create :accreditation

        @accreditation_attributes = @accreditation.attributes
        @accreditation_attributes.delete("id")
        @accreditation_attributes.delete("updated_at")
        @accreditation_attributes.delete("created_at")
        @accreditation_attributes["institution_name"] += "x"
      end

      it "assigns the accreditation record" do
        put :update, id: @accreditation.id, accreditation: @accreditation_attributes
        expect(assigns(:accreditation)).to eq(@accreditation)
      end

      it "updates an accreditation entry" do
        expect{ 
          put :update, id: @accreditation.id, accreditation: @accreditation_attributes 
        }.to change(Accreditation, :count).by(0)

        new_accreditation = Accreditation.find(@accreditation.id)
        expect(new_accreditation.institution).not_to eq(@accreditation.institution)
        expect(new_accreditation.updated_at).not_to eq(@accreditation.created_at)
      end 
    end

    context "having invalid form input" do
      context "with an invalid id" do
        before(:each) do
          @accreditation = create :accreditation

          @accreditation_attributes = @accreditation.attributes

          @accreditation_attributes.delete("id")
          @accreditation_attributes.delete("updated_at")
          @accreditation_attributes.delete("created_at")
        end

        it "with an invalid id it raises an error" do
          expect{ 
            put :update, id: 0, accreditation: @accreditation 
          }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context "with no agency_name" do
        before(:each) do
          @accreditation = create :accreditation

          @accreditation_attributes = @accreditation.attributes

          @accreditation_attributes.delete("id")
          @accreditation_attributes.delete("updated_at")
          @accreditation_attributes.delete("created_at")
          @accreditation_attributes["agency_name"] = nil
        end

        it "does not update a accreditation entry" do
          put :update, id: @accreditation.id, accreditation: @accreditation_attributes 

          new_accreditation = Accreditation.find(@accreditation.id)
          expect(new_accreditation.agency_name).to eq(@accreditation.agency_name)
        end
      end 

      context "with no csv_accreditation_type" do
        before(:each) do
          @accreditation = create :accreditation

          @accreditation_attributes = @accreditation.attributes
          @accreditation_attributes.delete("id")
          @accreditation_attributes.delete("updated_at")
          @accreditation_attributes.delete("created_at")
          @accreditation_attributes["csv_accreditation_type"] = nil
        end

        it "does not update a accreditation entry" do
          put :update, id: @accreditation.id, accreditation: @accreditation_attributes 

          new_accreditation = Accreditation.find(@accreditation.id)
          expect(new_accreditation.csv_accreditation_type).to eq(@accreditation.csv_accreditation_type)
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
      @accreditation = create :accreditation
    end

    context "with a valid id" do
      it "deletes a csv_file" do
        delete :destroy, id: @accreditation.id
        expect(assigns(:accreditation)).to eq(@accreditation)
      end

      it "deletes a scorecard record" do
        expect{ delete :destroy, id: @accreditation.id }.to change(Accreditation, :count).by(-1)
      end
    end

    context "with an invalid id" do
      it "raises an error" do
        expect{ delete :destroy, id: 0 }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
