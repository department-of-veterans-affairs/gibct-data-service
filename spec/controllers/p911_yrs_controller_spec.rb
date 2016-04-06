require 'rails_helper'

require 'support/controller_macros'
require 'support/devise'
require 'support/shared_examples_for_authentication'

RSpec.describe P911YrsController, type: :controller do
  it_behaves_like "an authenticating controller", :index, "p911_yrs"

  #############################################################################
  ## index
  #############################################################################
  describe "GET index" do
    login_user

    before(:each) do
      create :p911_yr
      @p911_yr = P911Yr.first

      get :index
    end

    it "populates an array of csvs" do
      expect(assigns(:p911_yrs)).to include(@p911_yr)
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
      @p911_yr = create :p911_yr
    end

    context "with a valid id" do
      it "populates a csv_file" do
        get :show, id: @p911_yr.id
        expect(assigns(:p911_yr)).to eq(@p911_yr)
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

    it "assigns a blank Post 911 YR record" do
      expect(assigns(:p911_yr)).to be_a_new(P911Yr)
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
        @p911_yr = attributes_for :p911_yr
      end

      it "creates a Post 911 YR entry" do
        expect{ post :create, p911_yr: @p911_yr }.to change(P911Yr, :count).by(1)
        expect(P911Yr.find_by(facility_code: @p911_yr[:facility_code])).not_to be_nil
      end 
    end

    context "having invalid form input" do 
      context "with no facility code" do
        before(:each) do
          @p911_yr = attributes_for :p911_yr, facility_code: nil
        end

        it "does not create a new csv file" do
          expect{ post :create, p911_yr: @p911_yr }.to change(P911Yr, :count).by(0)
        end
      end   

      context "with a duplicate facility code" do
        before(:each) do
          p911_yr = create :p911_yr
          @p911_yr = attributes_for :p911_yr, facility_code: p911_yr.facility_code
        end

        it "does not create a new csv file" do
          expect{ post :create, p911_yr: @p911_yr }.to change(P911Yr, :count).by(0)
        end
      end  

      context "with missing or non-numeric p911_yr_recipients" do
        it "does not create a new csv file" do
          p911_yr = attributes_for :p911_yr, p911_yr_recipients: 'abc'
          expect{ post :create, p911_yr: p911_yr }.to change(P911Yr, :count).by(0)
         
          p911_yr[:p911_yr_recipients] = nil
          expect{ post :create, p911_yr: p911_yr }.to change(P911Yr, :count).by(0)
        end
      end

      context "with missing or non-numeric p911_yellow_ribbon" do
        it "does not create a new csv file" do
          p911_yr = attributes_for :p911_yr, p911_yellow_ribbon: 'abc'
          expect{ post :create, p911_yr: p911_yr }.to change(P911Yr, :count).by(0)
         
          p911_yr[:p911_yellow_ribbon] = nil
          expect{ post :create, p911_yr: p911_yr }.to change(P911Yr, :count).by(0)
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
      @p911_yr = create :p911_yr
      get :edit, id: @p911_yr.id
    end

    context "with a valid id" do
      it "assigns a p911_yr record" do
        expect(assigns(:p911_yr)).to eq(@p911_yr)
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end
    end

    context "with an invalid id" do
      before(:each) do
        @p911_yr = create :p911_yr
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
        @p911_yr = create :p911_yr

        @p911_yr_attributes = @p911_yr.attributes
        @p911_yr_attributes.delete("id")
        @p911_yr_attributes.delete("updated_at")
        @p911_yr_attributes.delete("created_at")
        @p911_yr_attributes["institution"] += "x"
      end

      it "assigns the p911_yr record" do
        put :update, id: @p911_yr.id, p911_yr: @p911_yr_attributes
        expect(assigns(:p911_yr)).to eq(@p911_yr)
      end

      it "updates a p911_yr entry" do
        expect{ 
          put :update, id: @p911_yr.id, p911_yr: @p911_yr_attributes 
        }.to change(P911Yr, :count).by(0)

        new_p911_yr = P911Yr.find(@p911_yr.id)
        expect(new_p911_yr.institution).not_to eq(@p911_yr.institution)
        expect(new_p911_yr.updated_at).not_to eq(@p911_yr.created_at)
      end 
    end

    context "having invalid form input" do
      context "with an invalid id" do
        before(:each) do
          @p911_yr = create :p911_yr

          @p911_yr_attributes = @p911_yr.attributes

          @p911_yr_attributes.delete("id")
          @p911_yr_attributes.delete("updated_at")
          @p911_yr_attributes.delete("created_at")
        end

        it "with an invalid id it raises an error" do
          expect{ 
            put :update, id: 0, p911_yr: @p911_yr_attributes 
          }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
  
      context "with no facility code" do
        before(:each) do
          @p911_yr = create :p911_yr

          @p911_yr_attributes = @p911_yr.attributes
          @p911_yr_attributes.delete("id")
          @p911_yr_attributes.delete("updated_at")
          @p911_yr_attributes.delete("created_at")
          @p911_yr_attributes["facility_code"] = nil
        end

        it "does not update a p911_yr entry" do
          put :update, id: @p911_yr.id, p911_yr: @p911_yr_attributes 

          new_p911_yr = P911Yr.find(@p911_yr.id)
          expect(new_p911_yr.facility_code).to eq(@p911_yr.facility_code)
        end
      end 

      context "with a duplicate facility code" do
        before(:each) do
          @p911_yr = create :p911_yr
          @dup = create :p911_yr

          @p911_yr_attributes = @p911_yr.attributes
          @p911_yr_attributes.delete("id")
          @p911_yr_attributes.delete("updated_at")
          @p911_yr_attributes.delete("created_at")
          @p911_yr_attributes["facility_code"] = @dup.facility_code
        end

        it "does not update a p911_yr entry" do
          put :update, id: @p911_yr.id, p911_yr: @p911_yr_attributes 

          new_p911_yr = P911Yr.find(@p911_yr.id)
          expect(new_p911_yr.facility_code).to eq(@p911_yr.facility_code)
        end
      end   

      context "with missing or non-numeric p911_yr_recipients" do
        before(:each) do
          @p911_yr = create :p911_yr

          @p911_yr_attributes = @p911_yr.attributes
          @p911_yr_attributes.delete("id")
          @p911_yr_attributes.delete("updated_at")
          @p911_yr_attributes.delete("created_at")
        end

        it "does not update a p911_yr entry" do
          @p911_yr_attributes["p911_recipients"] = nil
          put :update, id: @p911_yr.id, p911_yr: @p911_yr_attributes 

          new_p911_yr = P911Yr.find(@p911_yr.id)
          expect(new_p911_yr.p911_yr_recipients).to eq(@p911_yr.p911_yr_recipients)

          @p911_yr_attributes["p911_recipients"] = 'abc'
          put :update, id: @p911_yr.id, p911_yr: @p911_yr_attributes 

          new_p911_yr = P911Yr.find(@p911_yr.id)
          expect(new_p911_yr.p911_yr_recipients).to eq(@p911_yr.p911_yr_recipients)
        end
      end   

      context "with missing or non-numeric p911_yellow_ribbon" do
        before(:each) do
          @p911_yr = create :p911_yr

          @p911_yr_attributes = @p911_yr.attributes
          @p911_yr_attributes.delete("id")
          @p911_yr_attributes.delete("updated_at")
          @p911_yr_attributes.delete("created_at")
        end

        it "does not update a p911_yr entry" do
          @p911_yr_attributes["p911_yellow_ribbon"] = nil
          put :update, id: @p911_yr.id, p911_yr: @p911_yr_attributes 

          new_p911_yr = P911Yr.find(@p911_yr.id)
          expect(new_p911_yr.p911_yellow_ribbon).to eq(@p911_yr.p911_yellow_ribbon)

          @p911_yr_attributes["p911_yellow_ribbon"] = 'abc'
          put :update, id: @p911_yr.id, p911_yr: @p911_yr_attributes 

          new_p911_yr = P911Yr.find(@p911_yr.id)
          expect(new_p911_yr.p911_yellow_ribbon).to eq(@p911_yr.p911_yellow_ribbon)
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
      @p911_yr = create :p911_yr
    end

    context "with a valid id" do
      it "assigns a csv_file" do
        delete :destroy, id: @p911_yr.id
        expect(assigns(:p911_yr)).to eq(@p911_yr)
      end

      it "deletes a p911_yr file record" do
        expect{ delete :destroy, id: @p911_yr.id }.to change(P911Yr, :count).by(-1)
      end
    end

    context "with an invalid id" do
      it "raises an error" do
        expect{ delete :destroy, id: 0 }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
