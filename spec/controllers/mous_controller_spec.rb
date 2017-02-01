require 'rails_helper'

require 'support/controller_macros'
require 'support/devise'
require 'support/shared_examples_for_authentication'

RSpec.describe MousController, type: :controller do
  it_behaves_like 'an authenticating controller', :index, 'mous'

  #############################################################################
  ## index
  #############################################################################
  describe 'GET index' do
    login_user

    before(:each) do
      create :mou
      @mou = Mou.first

      get :index
    end

    it 'populates an array of csvs' do
      expect(assigns(:mous)).to include(@mou)
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
      @mou = create :mou
    end

    context 'with a valid id' do
      it 'populates a csv_file' do
        get :show, id: @mou.id
        expect(assigns(:mou)).to eq(@mou)
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

    it 'assigns a blank mou record' do
      expect(assigns(:mou)).to be_a_new(Mou)
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
        @mou = attributes_for :mou
      end

      it 'creates an mou entry' do
        expect { post :create, mou: @mou }.to change(Mou, :count).by(1)
        expect(Mou.find_by(institution: @mou[:institution].upcase)).not_to be_nil
      end
    end

    context 'having invalid form input' do
      context 'with no ope' do
        before(:each) do
          @mou = attributes_for :mou, ope: nil
        end

        it 'does not create a new csv file' do
          expect { post :create, mou: @mou }.to change(Mou, :count).by(0)
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
      @mou = create :mou
      get :edit, id: @mou.id
    end

    context 'with a valid id' do
      it 'assigns an mou record' do
        expect(assigns(:mou)).to eq(@mou)
      end

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end
    end

    context 'with an invalid id' do
      before(:each) do
        @mou = create :mou
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
        @mou = create :mou

        @mou_attributes = @mou.attributes
        @mou_attributes.delete('id')
        @mou_attributes.delete('updated_at')
        @mou_attributes.delete('created_at')
        @mou_attributes['institution'] += 'x'
      end

      it 'assigns the mou record' do
        put :update, id: @mou.id, mou: @mou_attributes
        expect(assigns(:mou)).to eq(@mou)
      end

      it 'updates an mou entry' do
        expect do
          put :update, id: @mou.id, mou: @mou_attributes
        end.to change(Mou, :count).by(0)

        new_mou = Mou.find(@mou.id)
        expect(new_mou.institution).not_to eq(@mou.institution)
        expect(new_mou.updated_at).not_to eq(@mou.created_at)
      end
    end

    context 'having invalid form input' do
      context 'with an invalid id' do
        before(:each) do
          @mou = create :mou

          @mou_attributes = @mou.attributes

          @mou_attributes.delete('id')
          @mou_attributes.delete('updated_at')
          @mou_attributes.delete('created_at')
        end

        it 'with an invalid id it raises an error' do
          expect do
            put :update, id: 0, mou: @mou_attributes
          end.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context 'with no ope' do
        before(:each) do
          @mou = create :mou

          @mou_attributes = @mou.attributes
          @mou_attributes.delete('id')
          @mou_attributes.delete('updated_at')
          @mou_attributes.delete('created_at')
          @mou_attributes['ope'] = nil
        end

        it 'does not update a mou entry' do
          put :update, id: @mou.id, mou: @mou_attributes

          new_mou = Mou.find(@mou.id)
          expect(new_mou.institution).to eq(@mou.institution)
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
      @mou = create :mou
    end

    context 'with a valid id' do
      it 'deletes a csv_file' do
        delete :destroy, id: @mou.id
        expect(assigns(:mou)).to eq(@mou)
      end

      it 'deletes an mou record' do
        expect { delete :destroy, id: @mou.id }.to change(Mou, :count).by(-1)
      end
    end

    context 'with an invalid id' do
      it 'raises an error' do
        expect { delete :destroy, id: 0 }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
