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

  #############################################################################
  ## new
  #############################################################################
  describe "GET new" do
    login_user

    before(:each) do
      get :new
    end

    it "assigns a blank crosswalk record" do
      expect(assigns(:va_crosswalk)).to be_a_new(VaCrosswalk)
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
        @va_crosswalk = attributes_for :va_crosswalk
      end

      it "creates a crosswalk entry" do
        expect{ post :create, va_crosswalk: @va_crosswalk }.to change(VaCrosswalk, :count).by(1)
        expect(VaCrosswalk.find_by(facility_code: @va_crosswalk[:facility_code])).not_to be_nil
      end 
    end

    context "having invalid form input" do
      context "with no institution name" do
        before(:each) do
          @va_crosswalk = attributes_for :va_crosswalk, institution: nil
          end

        it "does not create a new csv file" do
          expect{ post :create, va_crosswalk: @va_crosswalk }.to change(VaCrosswalk, :count).by(0)
        end
      end   
  
      context "with no facility code" do
        before(:each) do
          @va_crosswalk = attributes_for :va_crosswalk, facility_code: nil
          end

        it "does not create a new csv file" do
          expect{ post :create, va_crosswalk: @va_crosswalk }.to change(VaCrosswalk, :count).by(0)
        end
      end   

      context "with a duplicate facility code" do
        before(:each) do
          v = create :va_crosswalk
          @va_crosswalk = attributes_for :va_crosswalk, facility_code: v.facility_code
          end

        it "does not create a new csv file" do
          expect{ post :create, va_crosswalk: @va_crosswalk }.to change(VaCrosswalk, :count).by(0)
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
      @va_crosswalk = create :va_crosswalk
      get :edit, id: @va_crosswalk.id
    end

    context "with a valid id" do
      it "assigns a VaCrosswalk record" do
        expect(assigns(:va_crosswalk)).to eq(@va_crosswalk)
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end
    end

    context "with an invalid id" do
      before(:each) do
        @va_crosswalk = create :va_crosswalk
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
        @va_crosswalk = create :va_crosswalk

        @va_crosswalk_attributes = @va_crosswalk.attributes
        @va_crosswalk_attributes.delete("id")
        @va_crosswalk_attributes.delete("updated_at")
        @va_crosswalk_attributes.delete("created_at")
        @va_crosswalk_attributes["institution"] += "x"
      end

      it "assigns the va_crosswalk record" do
        put :update, id: @va_crosswalk.id, va_crosswalk: @va_crosswalk_attributes
        expect(assigns(:va_crosswalk)).to eq(@va_crosswalk)
      end

      it "updates a va_crosswalk entry" do
        expect{ 
          put :update, id: @va_crosswalk.id, va_crosswalk: @va_crosswalk_attributes 
        }.to change(VaCrosswalk, :count).by(0)

        new_va_crosswalk = VaCrosswalk.find(@va_crosswalk.id)
        expect(new_va_crosswalk.institution).not_to eq(@va_crosswalk.institution)
        expect(new_va_crosswalk.updated_at).not_to eq(@va_crosswalk.created_at)
      end 
    end

    context "having invalid form input" do
      context "with an invalid id" do
        before(:each) do
          @va_crosswalk = create :va_crosswalk

          @va_crosswalk_attributes = @va_crosswalk.attributes

          @va_crosswalk_attributes.delete("id")
          @va_crosswalk_attributes.delete("updated_at")
          @va_crosswalk_attributes.delete("created_at")
        end

        it "with an invalid id it raises an error" do
          expect{ 
            put :update, id: 0, va_crosswalk: @va_crosswalk_attributes 
          }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context "with no institution name" do
        before(:each) do
          @va_crosswalk = create :va_crosswalk

          @va_crosswalk_attributes = @va_crosswalk.attributes
          @va_crosswalk_attributes.delete("id")
          @va_crosswalk_attributes.delete("updated_at")
          @va_crosswalk_attributes.delete("created_at")
          @va_crosswalk_attributes["institution"] = nil
        end

        it "does not update a va_crosswalk entry" do
          put :update, id: @va_crosswalk.id, va_crosswalk: @va_crosswalk_attributes 

          new_va_crosswalk = VaCrosswalk.find(@va_crosswalk.id)
          expect(new_va_crosswalk.institution).to eq(@va_crosswalk.institution)
        end
      end   
  
      context "with no facility code" do
        before(:each) do
          @va_crosswalk = create :va_crosswalk

          @va_crosswalk_attributes = @va_crosswalk.attributes
          @va_crosswalk_attributes.delete("id")
          @va_crosswalk_attributes.delete("updated_at")
          @va_crosswalk_attributes.delete("created_at")
          @va_crosswalk_attributes["facility_code"] = nil
        end

        it "does not update a va_crosswalk entry" do
          put :update, id: @va_crosswalk.id, va_crosswalk: @va_crosswalk_attributes 

          new_va_crosswalk = VaCrosswalk.find(@va_crosswalk.id)
          expect(new_va_crosswalk.facility_code).to eq(@va_crosswalk.facility_code)
        end
      end 

      context "with a duplicate facility code" do
        before(:each) do
          @va_crosswalk = create :va_crosswalk
          @dup = create :va_crosswalk

          @va_crosswalk_attributes = @va_crosswalk.attributes
          @va_crosswalk_attributes.delete("id")
          @va_crosswalk_attributes.delete("updated_at")
          @va_crosswalk_attributes.delete("created_at")
          @va_crosswalk_attributes["facility_code"] = @dup.facility_code
        end

        it "does not update a va_crosswalk entry" do
          put :update, id: @va_crosswalk.id, va_crosswalk: @va_crosswalk_attributes 

          new_va_crosswalk = VaCrosswalk.find(@va_crosswalk.id)
          expect(new_va_crosswalk.facility_code).to eq(@va_crosswalk.facility_code)
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
      @va_crosswalk = create :va_crosswalk
    end

    context "with a valid id" do
      it "assigns a csv_file" do
        delete :destroy, id: @va_crosswalk.id
        expect(assigns(:va_crosswalk)).to eq(@va_crosswalk)
      end

      it "deletes an va_crosswalk record" do
        expect{ delete :destroy, id: @va_crosswalk.id }.to change(VaCrosswalk, :count).by(-1)
      end
    end

    context "with an invalid id" do
      it "raises an error" do
        expect{ delete :destroy, id: 0 }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end