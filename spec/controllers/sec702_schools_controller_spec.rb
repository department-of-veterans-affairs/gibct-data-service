require 'rails_helper'

require 'support/controller_macros'
require 'support/devise'
require 'support/shared_examples_for_authentication'

RSpec.describe Sec702SchoolsController, type: :controller do
  it_behaves_like 'an authenticating controller', :index, 'sec702_schools'

  #############################################################################
  ## index
  #############################################################################
  describe 'GET index' do
    login_user

    before(:each) do
      create :sec702_school
      @sec702_school = Sec702School.first

      get :index
    end

    it 'populates an array of csvs' do
      expect(assigns(:sec702_schools)).to include(@sec702_school)
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
      @sec702_school = create :sec702_school
    end

    context 'with a valid id' do
      it 'populates a csv_file' do
        get :show, id: @sec702_school.id
        expect(assigns(:sec702_school)).to eq(@sec702_school)
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

    it 'assigns a blank sec702_school record' do
      expect(assigns(:sec702_school)).to be_a_new(Sec702School)
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
        @sec702_school = attributes_for :sec702_school
      end

      it 'creates a sec702 school entry' do
        expect { post :create, sec702_school: @sec702_school }.to change(Sec702School, :count).by(1)
        expect(Sec702School.find_by(facility_code: @sec702_school[:facility_code])).not_to be_nil
      end
    end

    context 'having invalid form input' do
      context 'with no facility code' do
        before(:each) do
          @sec702_school = attributes_for :sec702_school, facility_code: nil
        end

        it 'does not create a new csv file' do
          expect { post :create, sec702_school: @sec702_school }.to change(Sec702School, :count).by(0)
        end
      end

      context 'with a duplicate facility code' do
        before(:each) do
          w = create :sec702_school
          @sec702_school = attributes_for :sec702_school, facility_code: w.facility_code
        end

        it 'does not create a new csv file' do
          expect { post :create, sec702_school: @sec702_school }.to change(Sec702School, :count).by(0)
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
      @sec702_school = create :sec702_school
      get :edit, id: @sec702_school.id
    end

    context 'with a valid id' do
      it 'assigns a Sec702 School record' do
        expect(assigns(:sec702_school)).to eq(@sec702_school)
      end

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end
    end

    context 'with an invalid id' do
      it 'with an invalid id it raises an error' do
        expect { get :edit, id: 0 }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  #############################################################################
  ## edit
  #############################################################################
  describe 'PUT update' do
    login_user

    context 'having valid form input' do
      before(:each) do
        @sec702_school = create :sec702_school

        @sec702_school_attributes = @sec702_school.attributes
        @sec702_school_attributes.delete('id')
        @sec702_school_attributes.delete('updated_at')
        @sec702_school_attributes.delete('created_at')
        @sec702_school_attributes['sec_702'] = @sec702_school_attributes['sec_702'] ? false : true
      end

      it 'assigns the sec702 school record' do
        put :update, id: @sec702_school.id, sec702_school: @sec702_school_attributes
        expect(assigns(:sec702_school)).to eq(@sec702_school)
      end

      it 'updates a sec702 school entry' do
        expect do
          put :update, id: @sec702_school.id, sec702_school: @sec702_school_attributes
        end.to change(Sec702School, :count).by(0)

        new_sec702_school = Sec702School.find(@sec702_school.id)
        expect(new_sec702_school.sec_702).not_to eq(@sec702_school.sec_702)
        expect(new_sec702_school.updated_at).not_to eq(@sec702_school.created_at)
      end
    end

    context 'having invalid form input' do
      context 'with an invalid id' do
        before(:each) do
          @sec702_school = create :sec702_school

          @sec702_school_attributes = @sec702_school.attributes

          @sec702_school_attributes.delete('id')
          @sec702_school_attributes.delete('updated_at')
          @sec702_school_attributes.delete('created_at')
        end

        it 'with an invalid id it raises an error' do
          expect do
            put :update, id: 0, sec702_school: @sec702_school_attributes
          end.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context 'with no facility_code' do
        before(:each) do
          @sec702_school = create :sec702_school

          @sec702_school_attributes = @sec702_school.attributes
          @sec702_school_attributes.delete('id')
          @sec702_school_attributes.delete('updated_at')
          @sec702_school_attributes.delete('created_at')
          @sec702_school_attributes['facility_code'] = nil
        end

        it 'does not update a sec702 school entry' do
          put :update, id: @sec702_school.id, sec702_school: @sec702_school_attributes

          new_sec702_school = Sec702School.find(@sec702_school.id)
          expect(new_sec702_school.facility_code).to eq(@sec702_school.facility_code)
        end
      end

      context 'with a duplicate facility_code' do
        before(:each) do
          @sec702_school = create :sec702_school
          @dup = create :sec702_school

          @sec702_school_attributes = @sec702_school.attributes
          @sec702_school_attributes.delete('id')
          @sec702_school_attributes.delete('updated_at')
          @sec702_school_attributes.delete('created_at')
          @sec702_school_attributes['facility_code'] = @dup.facility_code
        end

        it 'does not update a sec702 school entry' do
          put :update, id: @sec702_school.id, sec702_school: @sec702_school_attributes

          new_sec702_school = Sec702School.find(@sec702_school.id)
          expect(new_sec702_school.facility_code).to eq(@sec702_school.facility_code)
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
      @sec702_school = create :sec702_school
    end

    context 'with a valid id' do
      it 'assigns a csv_file' do
        delete :destroy, id: @sec702_school.id
        expect(assigns(:sec702_school)).to eq(@sec702_school)
      end

      it 'deletes a sec702s school record' do
        expect { delete :destroy, id: @sec702_school.id }.to change(Sec702School, :count).by(-1)
      end
    end

    context 'with an invalid id' do
      it 'raises an error' do
        expect { delete :destroy, id: 0 }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
