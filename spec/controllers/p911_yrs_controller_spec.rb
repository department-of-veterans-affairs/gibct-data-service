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
      context "with no institution name" do
        before(:each) do
          @p911_yr = attributes_for :p911_yr, institution: nil
          end

        it "does not create a new csv file" do
          expect{ post :create, p911_yr: @p911_yr }.to change(P911Yr, :count).by(0)
        end
      end   
  
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
    end
  end
end
