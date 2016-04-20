require 'rails_helper'

require 'support/controller_macros'
require 'support/devise'
require 'support/shared_examples_for_authentication'

RSpec.describe ComplaintsController, type: :controller do
  it_behaves_like "an authenticating controller", :index, "complaints"

  #############################################################################
  ## index
  #############################################################################
  describe "GET index" do
    login_user

    before(:each) do
      create :complaint
      @complaint = Complaint.first

      get :index
    end

    it "populates an array of csvs" do
      expect(assigns(:complaints)).to include(@complaint)
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
      @complaint = create :complaint
    end

    context "with a valid id" do
      it "populates a csv_file" do
        get :show, id: @complaint.id
        expect(assigns(:complaint)).to eq(@complaint)
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

    it "assigns a blank complaint record" do
      expect(assigns(:complaint)).to be_a_new(Complaint)
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
        @complaint = attributes_for :complaint
      end

      it "creates a complaint entry" do
        expect{ post :create, complaint: @complaint }.to change(Complaint, :count).by(1)
        expect(Complaint.find_by(facility_code: @complaint[:facility_code])).not_to be_nil
      end 
    end

    context "having invalid form input" do
      context "with no status" do
        before(:each) do
          @complaint = attributes_for :complaint, status: nil
        end

        it "does not create a new csv file" do
          expect{ post :create, complaint: @complaint }.to change(Complaint, :count).by(0)
        end
      end

      context "with an invalid status" do
        before(:each) do
          @complaint = attributes_for :complaint, status: 'abc'
        end

        it "does not create a new csv file" do
          expect{ post :create, complaint: @complaint }.to change(Complaint, :count).by(0)
        end
      end

      context "with an invalid closed_reason" do
        before(:each) do
          @complaint = attributes_for :complaint, closed_reason: 'abc'
        end

        it "does not create a new csv file" do
          expect{ post :create, complaint: @complaint }.to change(Complaint, :count).by(0)
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
      @complaint = create :complaint
      get :edit, id: @complaint.id
    end

    context "with a valid id" do
      it "assigns an complaint record" do
        expect(assigns(:complaint)).to eq(@complaint)
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
  ## update
  #############################################################################
  describe "PUT update" do
    login_user
    
    context "having valid form input" do
      before(:each) do
        @complaint = create :complaint

        @complaint_attributes = @complaint.attributes
        @complaint_attributes.delete("id")
        @complaint_attributes.delete("updated_at")
        @complaint_attributes.delete("created_at")
        @complaint_attributes["institution"] += "x"
      end

      it "assigns the complaint record" do
        put :update, id: @complaint.id, complaint: @complaint_attributes
        expect(assigns(:complaint)).to eq(@complaint)
      end

      it "updates an complaint entry" do
        expect{ 
          put :update, id: @complaint.id, complaint: @complaint_attributes 
        }.to change(Complaint, :count).by(0)

        new_complaint = Complaint.find(@complaint.id)
        expect(new_complaint.institution).not_to eq(@complaint.institution)
        expect(new_complaint.updated_at).not_to eq(@complaint.created_at)
      end 
    end

    context "having invalid form input" do
      context "with an invalid id" do
        before(:each) do
          @complaint = create :complaint

          @complaint_attributes = @complaint.attributes

          @complaint_attributes.delete("id")
          @complaint_attributes.delete("updated_at")
          @complaint_attributes.delete("created_at")
        end

        it "with an invalid id it raises an error" do
          expect{ 
            put :update, id: 0, complaint: @complaint 
          }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context "with no status" do
        before(:each) do
          @complaint = create :complaint

          @complaint_attributes = @complaint.attributes

          @complaint_attributes.delete("id")
          @complaint_attributes.delete("updated_at")
          @complaint_attributes.delete("created_at")
          @complaint_attributes["status"] = nil
        end

        it "does not update a complaint entry" do
          put :update, id: @complaint.id, complaint: @complaint_attributes 

          new_complaint = Complaint.find(@complaint.id)
          expect(new_complaint.status).to eq(@complaint.status)
        end
      end 

      context "with an invalid status" do
        before(:each) do
          @complaint = create :complaint

          @complaint_attributes = @complaint.attributes

          @complaint_attributes.delete("id")
          @complaint_attributes.delete("updated_at")
          @complaint_attributes.delete("created_at")
          @complaint_attributes["status"] = "BLAH BLAH"
        end

        it "does not update a complaint entry" do
          put :update, id: @complaint.id, complaint: @complaint_attributes 

          new_complaint = Complaint.find(@complaint.id)
          expect(new_complaint.status).to eq(@complaint.status)
        end
      end

      context "with an invalid closed_reason" do
        before(:each) do
          @complaint = create :complaint

          @complaint_attributes = @complaint.attributes

          @complaint_attributes.delete("id")
          @complaint_attributes.delete("updated_at")
          @complaint_attributes.delete("created_at")
          @complaint_attributes["closed_reason"] = "BLAH BLAH"
        end

        it "does not update a complaint entry" do
          put :update, id: @complaint.id, complaint: @complaint_attributes 

          new_complaint = Complaint.find(@complaint.id)
          expect(new_complaint.closed_reason).to eq(@complaint.closed_reason)
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
      @complaint = create :complaint
    end

    context "with a valid id" do
      it "deletes a csv_file" do
        delete :destroy, id: @complaint.id
        expect(assigns(:complaint)).to eq(@complaint)
      end

      it "deletes a complaint record" do
        expect{ delete :destroy, id: @complaint.id }.to change(Complaint, :count).by(-1)
      end
    end

    context "with an invalid id" do
      it "raises an error" do
        expect{ delete :destroy, id: 0 }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
