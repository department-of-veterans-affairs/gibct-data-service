require 'rails_helper'

require 'support/controller_macros'
require 'support/devise'
require 'support/shared_examples_for_authentication'

RSpec.describe Sec702sController, type: :controller do
  it_behaves_like "an authenticating controller", :index, "sec702s"

  #############################################################################
  ## index
  #############################################################################
  describe "GET index" do
    login_user

    before(:each) do
      create :sec702
      @sec702 = Sec702.first

      get :index
    end

    it "populates an array of csvs" do
      expect(assigns(:sec702s)).to include(@sec702)
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
      @sec702 = create :sec702
    end

    context "with a valid id" do
      it "populates a csv_file" do
        get :show, id: @sec702.id
        expect(assigns(:sec702)).to eq(@sec702)
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

    it "assigns a blank crosswalk record" do
      expect(assigns(:sec702)).to be_a_new(Sec702)
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
        @sec702 = attributes_for :sec702
      end

      it "creates a sec702 entry" do
        expect{ post :create, sec702: @sec702 }.to change(Sec702, :count).by(1)
        expect(Sec702.find_by(state: @sec702[:state])).not_to be_nil
      end 
    end

    context "having invalid form input" do
      context "with no state name" do
        before(:each) do
          @sec702 = attributes_for :sec702, state: nil
        end

        it "does not create a new csv file" do
          expect{ post :create, sec702: @sec702 }.to change(Sec702, :count).by(0)
        end
      end   
  
      context "with a bad state code" do
        before(:each) do
          @sec702 = attributes_for :sec702, state: "ZZ"
        end

        it "does not create a new csv file" do
          expect{ post :create, sec702: @sec702 }.to change(Sec702, :count).by(0)
        end
      end   

      context "with a duplicate state" do
        before(:each) do
          w = create :sec702
          @sec702 = attributes_for :sec702, state: w.state
        end

        it "does not create a new csv file" do
          expect{ post :create, sec702: @sec702 }.to change(Sec702, :count).by(0)
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
      @sec702 = create :sec702
      get :edit, id: @sec702.id
    end

    context "with a valid id" do
      it "assigns a Sec702 record" do
        expect(assigns(:sec702)).to eq(@sec702)
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end
    end

    context "with an invalid id" do
      before(:each) do
        @sec702 = create :sec702
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
        @sec702 = create :sec702

        @sec702_attributes = @sec702.attributes
        @sec702_attributes.delete("id")
        @sec702_attributes.delete("updated_at")
        @sec702_attributes.delete("created_at")
        @sec702_attributes["sec_702"] = @sec702_attributes["sec_702"] == "no" ? 'yes' : 'no'
      end

      it "assigns the sec702 record" do
        put :update, id: @sec702.id, sec702: @sec702_attributes
        expect(assigns(:sec702)).to eq(@sec702)
      end

      it "updates a sec702 entry" do
        expect{ 
          put :update, id: @sec702.id, sec702: @sec702_attributes 
        }.to change(Sec702, :count).by(0)

        new_sec702 = Sec702.find(@sec702.id)
        expect(new_sec702.sec_702).not_to eq(@sec702.sec_702)
        expect(new_sec702.updated_at).not_to eq(@sec702.created_at)
      end 
    end

    context "having invalid form input" do
      context "with an invalid id" do
        before(:each) do
          @sec702 = create :sec702

          @sec702_attributes = @sec702.attributes

          @sec702_attributes.delete("id")
          @sec702_attributes.delete("updated_at")
          @sec702_attributes.delete("created_at")
        end

        it "with an invalid id it raises an error" do
          expect{ 
            put :update, id: 0, sec702: @sec702_attributes 
          }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context "with no state" do
        before(:each) do
          @sec702 = create :sec702

          @sec702_attributes = @sec702.attributes
          @sec702_attributes.delete("id")
          @sec702_attributes.delete("updated_at")
          @sec702_attributes.delete("created_at")
          @sec702_attributes["state"] = nil
        end

        it "does not update a sec702 entry" do
          put :update, id: @sec702.id, sec702: @sec702_attributes 

          new_sec702 = Sec702.find(@sec702.id)
          expect(new_sec702.state).to eq(@sec702.state)
        end
      end   
  
      context "with a bad state" do
        before(:each) do
          @sec702 = create :sec702

          @sec702_attributes = @sec702.attributes
          @sec702_attributes.delete("id")
          @sec702_attributes.delete("updated_at")
          @sec702_attributes.delete("created_at")
          @sec702_attributes["state"] = "ZZ"
        end

        it "does not update a sec702 entry" do
          put :update, id: @sec702.id, sec702: @sec702_attributes 

          new_sec702 = Sec702.find(@sec702.id)
          expect(new_sec702.state).not_to eq("ZZ")
        end
      end 

      context "with a duplicate state" do
        before(:each) do
          @sec702 = create :sec702
          @dup = create :sec702

          @sec702_attributes = @sec702.attributes
          @sec702_attributes.delete("id")
          @sec702_attributes.delete("updated_at")
          @sec702_attributes.delete("created_at")
          @sec702_attributes["state"] = @dup.state
        end

        it "does not update a sec702 entry" do
          put :update, id: @sec702.id, sec702: @sec702_attributes 

          new_sec702 = Sec702.find(@sec702.id)
          expect(new_sec702.state).to eq(@sec702.state)
        end
      end   
    end
  end
end
