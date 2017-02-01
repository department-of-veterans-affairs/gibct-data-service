require 'rails_helper'

require 'support/controller_macros'
require 'support/devise'
require 'support/shared_examples_for_authentication'

RSpec.describe IpedsHdsController, type: :controller do
  it_behaves_like 'an authenticating controller', :index, 'ipeds_hds'

  #############################################################################
  ## index
  #############################################################################
  describe 'GET index' do
    login_user

    before(:each) do
      create :ipeds_hd
      @ipeds_hd = IpedsHd.first

      get :index
    end

    it 'populates an array of csvs' do
      expect(assigns(:ipeds_hds)).to include(@ipeds_hd)
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
      @ipeds_hd = create :ipeds_hd
    end

    context 'with a valid id' do
      it 'populates a csv_file' do
        get :show, id: @ipeds_hd.id
        expect(assigns(:ipeds_hd)).to eq(@ipeds_hd)
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

    it 'assigns a blank ipeds_hd record' do
      expect(assigns(:ipeds_hd)).to be_a_new(IpedsHd)
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
        @ipeds_hd = attributes_for :ipeds_hd
      end

      it 'creates an ipeds_hd entry' do
        expect { post :create, ipeds_hd: @ipeds_hd }.to change(IpedsHd, :count).by(1)
        expect(IpedsHd.find_by(cross: @ipeds_hd[:cross])).not_to be_nil
      end
    end

    context 'having invalid form input' do
      context 'with no cross' do
        before(:each) do
          @ipeds_hd = attributes_for :ipeds_hd, cross: nil
        end

        it 'does not create a new csv file' do
          expect { post :create, ipeds_hd: @ipeds_hd }.to change(IpedsHd, :count).by(0)
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
      @ipeds_hd = create :ipeds_hd
      get :edit, id: @ipeds_hd.id
    end

    context 'with a valid id' do
      it 'assigns an ipeds_hd record' do
        expect(assigns(:ipeds_hd)).to eq(@ipeds_hd)
      end

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end
    end

    context 'with an invalid id' do
      before(:each) do
        @ipeds_hd = create :ipeds_hd
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
        @ipeds_hd = create :ipeds_hd

        @ipeds_hd_attributes = @ipeds_hd.attributes
        @ipeds_hd_attributes.delete('id')
        @ipeds_hd_attributes.delete('updated_at')
        @ipeds_hd_attributes.delete('created_at')
        @ipeds_hd_attributes['cross'] += 'x'
      end

      it 'assigns the ipeds_hd record' do
        put :update, id: @ipeds_hd.id, ipeds_hd: @ipeds_hd_attributes
        expect(assigns(:ipeds_hd)).to eq(@ipeds_hd)
      end

      it 'updates an ipeds_hd entry' do
        expect do
          put :update, id: @ipeds_hd.id, ipeds_hd: @ipeds_hd_attributes
        end.to change(IpedsHd, :count).by(0)

        new_ipeds_hd = IpedsHd.find(@ipeds_hd.id)
        expect(new_ipeds_hd.cross).not_to eq(@ipeds_hd.cross)
        expect(new_ipeds_hd.updated_at).not_to eq(@ipeds_hd.created_at)
      end
    end

    context 'having invalid form input' do
      context 'with an invalid id' do
        before(:each) do
          @ipeds_hd = create :ipeds_hd

          @ipeds_hd_attributes = @ipeds_hd.attributes

          @ipeds_hd_attributes.delete('id')
          @ipeds_hd_attributes.delete('updated_at')
          @ipeds_hd_attributes.delete('created_at')
        end

        it 'with an invalid id it raises an error' do
          expect do
            put :update, id: 0, ipeds_hd: @ipeds_hd_attributes
          end.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context 'with no cross' do
        before(:each) do
          @ipeds_hd = create :ipeds_hd

          @ipeds_hd_attributes = @ipeds_hd.attributes
          @ipeds_hd_attributes.delete('id')
          @ipeds_hd_attributes.delete('updated_at')
          @ipeds_hd_attributes.delete('created_at')
          @ipeds_hd_attributes['cross'] = nil
        end

        it 'does not update a ipeds_hd entry' do
          put :update, id: @ipeds_hd.id, ipeds_hd: @ipeds_hd_attributes

          new_ipeds_hd = IpedsHd.find(@ipeds_hd.id)
          expect(new_ipeds_hd.cross).to eq(@ipeds_hd.cross)
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
      @ipeds_hd = create :ipeds_hd
    end

    context 'with a valid id' do
      it 'deletes a csv_file' do
        delete :destroy, id: @ipeds_hd.id
        expect(assigns(:ipeds_hd)).to eq(@ipeds_hd)
      end

      it 'deletes an ipeds_hd record' do
        expect { delete :destroy, id: @ipeds_hd.id }.to change(IpedsHd, :count).by(-1)
      end
    end

    context 'with an invalid id' do
      it 'raises an error' do
        expect { delete :destroy, id: 0 }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
