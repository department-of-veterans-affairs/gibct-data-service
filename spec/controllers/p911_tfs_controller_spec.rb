require 'rails_helper'

require 'support/controller_macros'
require 'support/devise'
require 'support/shared_examples_for_authentication'

RSpec.describe P911TfsController, type: :controller do
  it_behaves_like "an authenticating controller", :index, "p911_tfs"

  #############################################################################
  ## index
  #############################################################################
  describe "GET index" do
    login_user

    before(:each) do
      create :p911_tf
      @p911_tf = P911Tf.first

      get :index
    end

    it "populates an array of csvs" do
      expect(assigns(:p911_tfs)).to include(@p911_tf)
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
      @p911_tf = create :p911_tf
    end

    context "with a valid id" do
      it "populates a csv_file" do
        get :show, id: @p911_tf.id
        expect(assigns(:p911_tf)).to eq(@p911_tf)
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

    it "assigns a blank Post 911 TF record" do
      expect(assigns(:p911_tf)).to be_a_new(P911Tf)
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
        @p911_tf = attributes_for :p911_tf
      end

      it "creates a Post 911 TF entry" do
        expect{ post :create, p911_tf: @p911_tf }.to change(P911Tf, :count).by(1)
        expect(P911Tf.find_by(facility_code: @p911_tf[:facility_code])).not_to be_nil
      end 
    end

    context "having invalid form input" do
      context "with no institution name" do
        before(:each) do
          @p911_tf = attributes_for :p911_tf, institution: nil
          end

        it "does not create a new csv file" do
          expect{ post :create, p911_tf: @p911_tf }.to change(P911Tf, :count).by(0)
        end
      end   
  
      context "with no facility code" do
        before(:each) do
          @p911_tf = attributes_for :p911_tf, facility_code: nil
          end

        it "does not create a new csv file" do
          expect{ post :create, p911_tf: @p911_tf }.to change(P911Tf, :count).by(0)
        end
      end   

      context "with a duplicate facility code" do
        before(:each) do
          p911_tf = create :p911_tf
          @p911_tf = attributes_for :p911_tf, facility_code: p911_tf.facility_code
          end

        it "does not create a new csv file" do
          expect{ post :create, p911_tf: @p911_tf }.to change(P911Tf, :count).by(0)
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
      @p911_tf = create :p911_tf
      get :edit, id: @p911_tf.id
    end

    context "with a valid id" do
      it "assigns a p911_tf record" do
        expect(assigns(:p911_tf)).to eq(@p911_tf)
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end
    end

    context "with an invalid id" do
      before(:each) do
        @p911_tf = create :p911_tf
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
        @p911_tf = create :p911_tf

        @p911_tf_attributes = @p911_tf.attributes
        @p911_tf_attributes.delete("id")
        @p911_tf_attributes.delete("updated_at")
        @p911_tf_attributes.delete("created_at")
        @p911_tf_attributes["institution"] += "x"
      end

      it "assigns the p911_tf record" do
        put :update, id: @p911_tf.id, p911_tf: @p911_tf_attributes
        expect(assigns(:p911_tf)).to eq(@p911_tf)
      end

      it "updates a p911_tf entry" do
        expect{ 
          put :update, id: @p911_tf.id, p911_tf: @p911_tf_attributes 
        }.to change(P911Tf, :count).by(0)

        new_p911_tf = P911Tf.find(@p911_tf.id)
        expect(new_p911_tf.institution).not_to eq(@p911_tf.institution)
        expect(new_p911_tf.updated_at).not_to eq(@p911_tf.created_at)
      end 
    end

    context "having invalid form input" do
      context "with an invalid id" do
        before(:each) do
          @p911_tf = create :p911_tf

          @p911_tf_attributes = @p911_tf.attributes

          @p911_tf_attributes.delete("id")
          @p911_tf_attributes.delete("updated_at")
          @p911_tf_attributes.delete("created_at")
        end

        it "with an invalid id it raises an error" do
          expect{ 
            put :update, id: 0, p911_tf: @p911_tf_attributes 
          }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context "with no institution name" do
        before(:each) do
          @p911_tf = create :p911_tf

          @p911_tf_attributes = @p911_tf.attributes
          @p911_tf_attributes.delete("id")
          @p911_tf_attributes.delete("updated_at")
          @p911_tf_attributes.delete("created_at")
          @p911_tf_attributes["institution"] = nil
        end

        it "does not update a p911_tf entry" do
          put :update, id: @p911_tf.id, p911_tf: @p911_tf_attributes 

          new_p911_tf = P911Tf.find(@p911_tf.id)
          expect(new_p911_tf.institution).to eq(@p911_tf.institution)
        end
      end   
  
      context "with no facility code" do
        before(:each) do
          @p911_tf = create :p911_tf

          @p911_tf_attributes = @p911_tf.attributes
          @p911_tf_attributes.delete("id")
          @p911_tf_attributes.delete("updated_at")
          @p911_tf_attributes.delete("created_at")
          @p911_tf_attributes["facility_code"] = nil
        end

        it "does not update a p911_tf entry" do
          put :update, id: @p911_tf.id, p911_tf: @p911_tf_attributes 

          new_p911_tf = P911Tf.find(@p911_tf.id)
          expect(new_p911_tf.facility_code).to eq(@p911_tf.facility_code)
        end
      end 

      context "with a duplicate facility code" do
        before(:each) do
          @p911_tf = create :p911_tf
          @dup = create :p911_tf

          @p911_tf_attributes = @p911_tf.attributes
          @p911_tf_attributes.delete("id")
          @p911_tf_attributes.delete("updated_at")
          @p911_tf_attributes.delete("created_at")
          @p911_tf_attributes["facility_code"] = @dup.facility_code
        end

        it "does not update a p911_tf entry" do
          put :update, id: @p911_tf.id, p911_tf: @p911_tf_attributes 

          new_p911_tf = P911Tf.find(@p911_tf.id)
          expect(new_p911_tf.facility_code).to eq(@p911_tf.facility_code)
        end
      end  

      context "with no total count of students" do
        before(:each) do
          @p911_tf = create :p911_tf

          @p911_tf_attributes = @p911_tf.attributes
          @p911_tf_attributes.delete("id")
          @p911_tf_attributes.delete("updated_at")
          @p911_tf_attributes.delete("created_at")
          @p911_tf_attributes["total_count_of_students"] = nil
        end

        it "does not update a p911_tf entry" do
          put :update, id: @p911_tf.id, p911_tf: @p911_tf_attributes 

          new_p911_tf = P911Tf.find(@p911_tf.id)
          expect(new_p911_tf.facility_code).to eq(@p911_tf.facility_code)
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
      @p911_tf = create :p911_tf
    end

    context "with a valid id" do
      it "assigns a csv_file" do
        delete :destroy, id: @p911_tf.id
        expect(assigns(:p911_tf)).to eq(@p911_tf)
      end

      it "deletes a p911_tfs file record" do
        expect{ delete :destroy, id: @p911_tf.id }.to change(P911Tf, :count).by(-1)
      end
    end

    context "with an invalid id" do
      it "raises an error" do
        expect{ delete :destroy, id: 0 }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
