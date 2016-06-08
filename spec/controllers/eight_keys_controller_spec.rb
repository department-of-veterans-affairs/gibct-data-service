require 'rails_helper'

require 'support/controller_macros'
require 'support/devise'
require 'support/shared_examples_for_authentication'

RSpec.describe EightKeysController, type: :controller do
  it_behaves_like "an authenticating controller", :index, "eight_keys"

  #############################################################################
  ## index
  #############################################################################
  describe "GET index" do
    login_user

    before(:each) do
      create :eight_key
      @eight_key = EightKey.first

      get :index
    end

    it "populates an array of csvs" do
      expect(assigns(:eight_keys)).to include(@eight_key)
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
      @eight_key = create :eight_key
    end

    context "with a valid id" do
      it "populates a csv_file" do
        get :show, id: @eight_key.id
        expect(assigns(:eight_key)).to eq(@eight_key)
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
      expect(assigns(:eight_key)).to be_a_new(EightKey)
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
        @eight_key = attributes_for :eight_key
      end

      it "creates an eight key entry" do
        expect{ post :create, eight_key: @eight_key }.to change(EightKey, :count).by(1)
        expect(EightKey.find_by(institution: @eight_key[:institution].upcase)).not_to be_nil
      end 
    end

    context "having invalid form input" do
      before(:each) do
        @eight_key = attributes_for :eight_key
      end

      it "does not create a new eight_key entry" do
        class E
          def full_messages
            []
          end
        end

        dbl_eight_key = instance_double('EightKey', save: false, persisted?: false, errors: E.new)
        allow(EightKey).to receive(:new).and_return(dbl_eight_key)

        expect{ post :create, eight_key: @eight_key }.to change(EightKey, :count).by(0)
        expect(EightKey.find_by(ope6: @eight_key[:ope6])).to be_nil
      end 
    end

  end

  #############################################################################
  ## edit
  #############################################################################
  describe "GET edit" do
    login_user

    before(:each) do
      @eight_key = create :eight_key
      get :edit, id: @eight_key.id
    end

    context "with a valid id" do
      it "assigns an eight key record" do
        expect(assigns(:eight_key)).to eq(@eight_key)
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end
    end

    context "with an invalid id" do
      before(:each) do
        @eight_key = create :eight_key
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
        @eight_key = create :eight_key

        @eight_key_attributes = @eight_key.attributes
        @eight_key_attributes.delete("id")
        @eight_key_attributes.delete("updated_at")
        @eight_key_attributes.delete("created_at")
        @eight_key_attributes["institution"] += "x"
      end

      it "assigns the eight_key record" do
        put :update, id: @eight_key.id, eight_key: @eight_key_attributes
        expect(assigns(:eight_key)).to eq(@eight_key)
      end

      it "updates an eight_key entry" do
        expect{ 
          put :update, id: @eight_key.id, eight_key: @eight_key_attributes 
        }.to change(EightKey, :count).by(0)

        new_eight_key = EightKey.find(@eight_key.id)
        expect(new_eight_key.institution).not_to eq(@eight_key.institution)
        expect(new_eight_key.updated_at).not_to eq(@eight_key.created_at)
      end 
    end

    context "having invalid form input" do
      context "with an invalid id" do
        before(:each) do
          @eight_key = create :eight_key

          @eight_key_attributes = @eight_key.attributes

          @eight_key_attributes.delete("id")
          @eight_key_attributes.delete("updated_at")
          @eight_key_attributes.delete("created_at")
        end

        it "with an invalid id it raises an error" do
          expect{ 
            put :update, id: 0, eight_key: @eight_key_attributes 
          }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context "having invalid form input" do
        before(:each) do
          @eight_key = create :eight_key

          @eight_key_attributes = @eight_key.attributes

          @eight_key_attributes.delete("id")
          @eight_key_attributes.delete("updated_at")
          @eight_key_attributes.delete("created_at")
          @eight_key_attributes["institution"] += "x"
        end

        it "does not create a new eight_key entry" do
          class E
            def full_messages
              []
            end
          end

          dbl_eight_key = instance_double('EightKey', update: false, persisted?: false, errors: E.new)
          allow(EightKey).to receive(:find).and_return(dbl_eight_key)

          expect{ 
            put :update, id: @eight_key.id, eight_key: @eight_key_attributes 
          }.to change(EightKey, :count).by(0)

          expect(EightKey.find_by(id: @eight_key.id).institution).to eq(@eight_key.institution)
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
      @eight_key = create :eight_key
    end

    context "with a valid id" do
      it "deletes a csv_file" do
        delete :destroy, id: @eight_key.id
        expect(assigns(:eight_key)).to eq(@eight_key)
      end

      it "deletes an eight_key record" do
        expect{ delete :destroy, id: @eight_key.id }.to change(EightKey, :count).by(-1)
      end
    end

    context "with an invalid id" do
      it "raises an error" do
        expect{ delete :destroy, id: 0 }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
