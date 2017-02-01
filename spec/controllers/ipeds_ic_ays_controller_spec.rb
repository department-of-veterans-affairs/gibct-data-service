require 'rails_helper'

require 'support/controller_macros'
require 'support/devise'
require 'support/shared_examples_for_authentication'

RSpec.describe IpedsIcAysController, type: :controller do
  it_behaves_like 'an authenticating controller', :index, 'ipeds_ic_ays'

  #############################################################################
  ## index
  #############################################################################
  describe 'GET index' do
    login_user

    before(:each) do
      create :ipeds_ic_ay
      @ipeds_ic_ay = IpedsIcAy.first

      get :index
    end

    it 'populates an array of csvs' do
      expect(assigns(:ipeds_ic_ays)).to include(@ipeds_ic_ay)
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end
  end

  #############################################################################
  ## show
  #############################################################################
  describe 'GET show' do
    login_user

    before(:each) do
      @ipeds_ic_ay = create :ipeds_ic_ay
    end

    context 'with a valid id' do
      it 'populates a csv_file' do
        get :show, id: @ipeds_ic_ay.id
        expect(assigns(:ipeds_ic_ay)).to eq(@ipeds_ic_ay)
      end
    end

    context 'with a invalid id' do
      it 'raises an error' do
        expect { get :show, id: 0 }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  #############################################################################
  ## new
  #############################################################################
  describe 'GET new' do
    login_user

    before(:each) do
      get :new
    end

    it 'assigns a blank ipeds_ic_ay record' do
      expect(assigns(:ipeds_ic_ay)).to be_a_new(IpedsIcAy)
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end
  end

  #############################################################################
  ## create
  #############################################################################
  describe 'POST create' do
    login_user

    context 'having valid form input' do
      before(:each) do
        @ipeds_ic_ay = attributes_for :ipeds_ic_ay
      end

      it 'creates an ipeds_ic_ay entry' do
        expect { post :create, ipeds_ic_ay: @ipeds_ic_ay }.to change(IpedsIcAy, :count).by(1)
        expect(IpedsIcAy.find_by(cross: @ipeds_ic_ay[:cross])).not_to be_nil
      end
    end

    context 'having invalid form input' do
      context 'with no cross' do
        before(:each) do
          @ipeds_ic_ay = attributes_for :ipeds_ic_ay, cross: nil
        end

        it 'does not create a new csv file' do
          expect { post :create, ipeds_ic_ay: @ipeds_ic_ay }.to change(IpedsIcAy, :count).by(0)
        end
      end
    end
  end

  #############################################################################
  ## edit
  #############################################################################
  describe 'GET edit' do
    login_user

    before(:each) do
      @ipeds_ic_ay = create :ipeds_ic_ay
      get :edit, id: @ipeds_ic_ay.id
    end

    context 'with a valid id' do
      it 'assigns an ipeds_ic_ay record' do
        expect(assigns(:ipeds_ic_ay)).to eq(@ipeds_ic_ay)
      end

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end
    end

    context 'with an invalid id' do
      before(:each) do
        @ipeds_ic_ay = create :ipeds_ic_ay
      end

      it 'with an invalid id it raises an error' do
        expect { get :edit, id: 0 }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  #############################################################################
  ## update
  #############################################################################
  describe 'PUT update' do
    login_user

    context 'having valid form input' do
      before(:each) do
        @ipeds_ic_ay = create :ipeds_ic_ay

        @ipeds_ic_ay_attributes = @ipeds_ic_ay.attributes
        @ipeds_ic_ay_attributes.delete('id')
        @ipeds_ic_ay_attributes.delete('updated_at')
        @ipeds_ic_ay_attributes.delete('created_at')
        @ipeds_ic_ay_attributes['cross'] += 'x'
      end

      it 'assigns the ipeds_ic_ay record' do
        put :update, id: @ipeds_ic_ay.id, ipeds_ic_ay: @ipeds_ic_ay_attributes
        expect(assigns(:ipeds_ic_ay)).to eq(@ipeds_ic_ay)
      end

      it 'updates an ipeds_ic_ay entry' do
        expect do
          put :update, id: @ipeds_ic_ay.id, ipeds_ic_ay: @ipeds_ic_ay_attributes
        end.to change(IpedsIcAy, :count).by(0)

        new_ipeds_ic_ay = IpedsIcAy.find(@ipeds_ic_ay.id)
        expect(new_ipeds_ic_ay.cross).not_to eq(@ipeds_ic_ay.cross)
        expect(new_ipeds_ic_ay.updated_at).not_to eq(@ipeds_ic_ay.created_at)
      end
    end

    context 'having invalid form input' do
      context 'with an invalid id' do
        before(:each) do
          @ipeds_ic_ay = create :ipeds_ic_ay

          @ipeds_ic_ay_attributes = @ipeds_ic_ay.attributes

          @ipeds_ic_ay_attributes.delete('id')
          @ipeds_ic_ay_attributes.delete('updated_at')
          @ipeds_ic_ay_attributes.delete('created_at')
        end

        it 'with an invalid id it raises an error' do
          expect do
            put :update, id: 0, ipeds_ic_ay: @ipeds_ic_ay_attributes
          end.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context 'with no cross' do
        before(:each) do
          @ipeds_ic_ay = create :ipeds_ic_ay

          @ipeds_ic_ay_attributes = @ipeds_ic_ay.attributes
          @ipeds_ic_ay_attributes.delete('id')
          @ipeds_ic_ay_attributes.delete('updated_at')
          @ipeds_ic_ay_attributes.delete('created_at')
          @ipeds_ic_ay_attributes['cross'] = nil
        end

        it 'does not update a ipeds_ic_ay entry' do
          put :update, id: @ipeds_ic_ay.id, ipeds_ic_ay: @ipeds_ic_ay_attributes

          new_ipeds_ic = IpedsIcAy.find(@ipeds_ic_ay.id)
          expect(new_ipeds_ic.cross).to eq(@ipeds_ic_ay.cross)
        end
      end
    end
  end

  #############################################################################
  ## destroy
  #############################################################################
  describe 'DELETE destroy' do
    login_user

    before(:each) do
      @ipeds_ic_ay = create :ipeds_ic_ay
    end

    context 'with a valid id' do
      it 'deletes a csv_file' do
        delete :destroy, id: @ipeds_ic_ay.id
        expect(assigns(:ipeds_ic_ay)).to eq(@ipeds_ic_ay)
      end

      it 'deletes an ipeds_ic_ay record' do
        expect { delete :destroy, id: @ipeds_ic_ay.id }.to change(IpedsIcAy, :count).by(-1)
      end
    end

    context 'with an invalid id' do
      it 'raises an error' do
        expect { delete :destroy, id: 0 }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
