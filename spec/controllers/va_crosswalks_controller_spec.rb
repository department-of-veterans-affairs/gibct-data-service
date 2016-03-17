require 'rails_helper'

require 'support/controller_macros'
require 'support/devise'
require 'support/shared_examples_for_authentication'

RSpec.describe VaCrosswalksController, type: :controller do
  it_behaves_like "an authenticating controller", :index, "va_crosswalks"

  #############################################################################
  ## index
  #############################################################################
  describe "GET index" do
    login_user

    before(:each) do
      create :va_crosswalk
      @va_crosswalk = VaCrosswalk.first

      get :index
    end

    it "populates an array of csvs" do
      expect(assigns(:va_crosswalks)).to include(@va_crosswalk)
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
      @va_crosswalk = create :va_crosswalk
    end

    context "with a valid id" do
      it "populates a csv_file" do
        get :show, id: @va_crosswalk.id
        expect(assigns(:va_crosswalk)).to eq(@va_crosswalk)
      end
    end

    context "with a invalid id" do
      it "raises an error" do
        expect{ get :show, id: 0 }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end