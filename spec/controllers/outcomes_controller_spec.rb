require 'rails_helper'

require 'support/controller_macros'
require 'support/devise'
require 'support/shared_examples_for_authentication'

RSpec.describe OutcomesController, type: :controller do
  it_behaves_like "an authenticating controller", :index, "outcomes"

  #############################################################################
  ## index
  #############################################################################
  describe "GET index" do
    login_user

    before(:each) do
      create :outcome
      @outcome = Outcome.first

      get :index
    end

    it "populates an array of csvs" do
      expect(assigns(:outcomes)).to include(@outcome)
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
      @outcome = create :outcome
    end

    context "with a valid id" do
      it "populates a csv_file" do
        get :show, id: @outcome.id
        expect(assigns(:outcome)).to eq(@outcome)
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

    it "assigns a blank Outcome instance" do
      expect(assigns(:outcome)).to be_a_new(Outcome)
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
        @outcome = attributes_for :outcome
      end

      it "creates a Outcome entry" do
        expect{ post :create, outcome: @outcome }.to change(Outcome, :count).by(1)
        expect(Outcome.find_by(facility_code: @outcome[:facility_code])).not_to be_nil
      end 
    end

    context "having invalid form input" do 
      context "with no facility code" do
        before(:each) do
          @outcome = attributes_for :outcome, facility_code: nil
        end

        it "does not create a new csv file" do
          expect{ post :create, outcome: @outcome }.to change(P911Tf, :count).by(0)
        end
      end   

      context "with a duplicate facility code" do
        before(:each) do
          outcome = create :outcome
          @outcome = attributes_for :outcome, facility_code: outcome.facility_code
        end

        it "does not create a new csv file" do
          expect{ post :create, outcome: @outcome }.to change(Outcome, :count).by(0)
        end
      end   

      context "with an invalid retention_rate_veteran_ba" do
        it "does not create a new csv file" do
          outcome = attributes_for :outcome, retention_rate_veteran_ba: 'abc'
          expect{ post :create, outcome: outcome }.to change(Outcome, :count).by(0)
        end
      end

      context "with an invalid retention_rate_veteran_otb" do
        it "does not create a new csv file" do
          outcome = attributes_for :outcome, retention_rate_veteran_otb: 'abc'
          expect{ post :create, outcome: outcome }.to change(Outcome, :count).by(0)
        end
      end

      context "with an invalid persistance_rate_veteran_ba" do
        it "does not create a new csv file" do
          outcome = attributes_for :outcome, persistance_rate_veteran_ba: 'abc'
          expect{ post :create, outcome: outcome }.to change(Outcome, :count).by(0)
        end
      end

      context "with an invalid persistance_rate_veteran_otb" do
        it "does not create a new csv file" do
          outcome = attributes_for :outcome, persistance_rate_veteran_otb: 'abc'
          expect{ post :create, outcome: outcome }.to change(Outcome, :count).by(0)
        end
      end

      context "with an invalid graduation_rate_veteran" do
        it "does not create a new csv file" do
          outcome = attributes_for :outcome, graduation_rate_veteran: 'abc'
          expect{ post :create, outcome: outcome }.to change(Outcome, :count).by(0)
        end
      end

      context "with an invalid transfer_out_rate_veteran" do
        it "does not create a new csv file" do
          outcome = attributes_for :outcome, transfer_out_rate_veteran: 'abc'
          expect{ post :create, outcome: outcome }.to change(Outcome, :count).by(0)
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
      @outcome = create :outcome
      get :edit, id: @outcome.id
    end

    context "with a valid id" do
      it "assigns an Outcome instance" do
        expect(assigns(:outcome)).to eq(@outcome)
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end
    end

    context "with an invalid id" do
      before(:each) do
        @outcome = create :outcome
      end

      it "raises an error" do
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
        @outcome = create :outcome

        @outcome_attributes = @outcome.attributes
        @outcome_attributes.delete("id")
        @outcome_attributes.delete("updated_at")
        @outcome_attributes.delete("created_at")
        @outcome_attributes["institution"] += "x"
      end

      it "assigns the outcome record" do
        put :update, id: @outcome.id, outcome: @outcome_attributes
        expect(assigns(:outcome)).to eq(@outcome)
      end

      it "updates a outcome entry" do
        expect{ 
          put :update, id: @outcome.id, outcome: @outcome_attributes 
        }.to change(P911Tf, :count).by(0)

        new_outcome = Outcome.find(@outcome.id)
        expect(new_outcome.institution).not_to eq(@outcome.institution)
        expect(new_outcome.updated_at).not_to eq(@outcome.created_at)
      end 
    end

    context "having invalid form input" do
      context "with an invalid id" do
        before(:each) do
          @outcome = create :outcome

          @outcome_attributes = @outcome.attributes

          @outcome_attributes.delete("id")
          @outcome_attributes.delete("updated_at")
          @outcome_attributes.delete("created_at")
        end

        it "with an invalid id it raises an error" do
          expect{ 
            put :update, id: 0, outcome: @outcome_attributes 
          }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
  
      context "with no facility code" do
        before(:each) do
          @outcome = create :outcome

          @outcome_attributes = @outcome.attributes
          @outcome_attributes.delete("id")
          @outcome_attributes.delete("updated_at")
          @outcome_attributes.delete("created_at")
          @outcome_attributes["facility_code"] = nil
        end

        it "does not update a outcome entry" do
          put :update, id: @outcome.id, outcome: @outcome_attributes 

          new_outcome = Outcome.find(@outcome.id)
          expect(new_outcome.facility_code).to eq(@outcome.facility_code)
        end
      end 

      context "with a duplicate facility code" do
        before(:each) do
          @outcome = create :outcome
          @dup = create :outcome

          @outcome_attributes = @outcome.attributes
          @outcome_attributes.delete("id")
          @outcome_attributes.delete("updated_at")
          @outcome_attributes.delete("created_at")
          @outcome_attributes["facility_code"] = @dup.facility_code
        end

        it "does not update a outcome entry" do
          put :update, id: @outcome.id, outcome: @outcome_attributes 

          new_outcome = Outcome.find(@outcome.id)
          expect(new_outcome.facility_code).to eq(@outcome.facility_code)
        end
      end   

      context "with a non-numeric retention_rate_veteran_ba" do
        before(:each) do
          @outcome = create :outcome

          @outcome_attributes = @outcome.attributes
          @outcome_attributes.delete("id")
          @outcome_attributes.delete("updated_at")
          @outcome_attributes.delete("created_at")
        end

        it "does not update a outcome entry" do
          @outcome_attributes["retention_rate_veteran_ba"] = 'abc'
          put :update, id: @outcome.id, outcome: @outcome_attributes 

          new_outcome = Outcome.find(@outcome.id)
          expect(new_outcome.retention_rate_veteran_ba).to eq(@outcome.retention_rate_veteran_ba)
        end
      end   

      context "with non-numeric retention_rate_veteran_otb" do
        before(:each) do
          @outcome = create :outcome

          @outcome_attributes = @outcome.attributes
          @outcome_attributes.delete("id")
          @outcome_attributes.delete("updated_at")
          @outcome_attributes.delete("created_at")
        end

        it "does not update a outcome entry" do
          @outcome_attributes["retention_rate_veteran_otb"] = 'abc'
          put :update, id: @outcome.id, outcome: @outcome_attributes 

          new_outcome = Outcome.find(@outcome.id)
          expect(new_outcome.retention_rate_veteran_otb).to eq(@outcome.retention_rate_veteran_otb)
        end
      end 

      context "with non-numeric persistance_rate_veteran_ba" do
        before(:each) do
          @outcome = create :outcome

          @outcome_attributes = @outcome.attributes
          @outcome_attributes.delete("id")
          @outcome_attributes.delete("updated_at")
          @outcome_attributes.delete("created_at")
        end

        it "does not update a outcome entry" do
          @outcome_attributes["persistance_rate_veteran_ba"] = 'abc'
          put :update, id: @outcome.id, outcome: @outcome_attributes 

          new_outcome = Outcome.find(@outcome.id)
          expect(new_outcome.persistance_rate_veteran_ba).to eq(@outcome.persistance_rate_veteran_ba)
        end
      end

      context "with non-numeric persistance_rate_veteran_otb" do
        before(:each) do
          @outcome = create :outcome

          @outcome_attributes = @outcome.attributes
          @outcome_attributes.delete("id")
          @outcome_attributes.delete("updated_at")
          @outcome_attributes.delete("created_at")
        end

        it "does not update a outcome entry" do
          @outcome_attributes["persistance_rate_veteran_otb"] = 'abc'
          put :update, id: @outcome.id, outcome: @outcome_attributes 

          new_outcome = Outcome.find(@outcome.id)
          expect(new_outcome.persistance_rate_veteran_otb).to eq(@outcome.persistance_rate_veteran_otb)
        end
      end

      context "with non-numeric graduation_rate_veteran" do
        before(:each) do
          @outcome = create :outcome

          @outcome_attributes = @outcome.attributes
          @outcome_attributes.delete("id")
          @outcome_attributes.delete("updated_at")
          @outcome_attributes.delete("created_at")
        end

        it "does not update a outcome entry" do
          @outcome_attributes["graduation_rate_veteran"] = 'abc'
          put :update, id: @outcome.id, outcome: @outcome_attributes 

          new_outcome = Outcome.find(@outcome.id)
          expect(new_outcome.graduation_rate_veteran).to eq(@outcome.graduation_rate_veteran)
        end
      end

      context "with non-numeric transfer_out_rate_veteran" do
        before(:each) do
          @outcome = create :outcome

          @outcome_attributes = @outcome.attributes
          @outcome_attributes.delete("id")
          @outcome_attributes.delete("updated_at")
          @outcome_attributes.delete("created_at")
        end

        it "does not update a outcome entry" do
          @outcome_attributes["transfer_out_rate_veteran"] = 'abc'
          put :update, id: @outcome.id, outcome: @outcome_attributes 

          new_outcome = Outcome.find(@outcome.id)
          expect(new_outcome.transfer_out_rate_veteran).to eq(@outcome.transfer_out_rate_veteran)
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
      @outcome = create :outcome
    end

    context "with a valid id" do
      it "assigns a csv_file" do
        delete :destroy, id: @outcome.id
        expect(assigns(:outcome)).to eq(@outcome)
      end

      it "deletes a outcomes file record" do
        expect{ delete :destroy, id: @outcome.id }.to change(Outcome, :count).by(-1)
      end
    end

    context "with an invalid id" do
      it "raises an error" do
        expect{ delete :destroy, id: 0 }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
