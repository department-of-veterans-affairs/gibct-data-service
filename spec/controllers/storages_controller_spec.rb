# frozen_string_literal: true

require 'rails_helper'
require 'support/controller_macros'
require 'support/devise'
require 'controllers/shared_examples/shared_examples_for_authentication'

RSpec.describe StoragesController, type: :controller do
  it_behaves_like 'an authenticating controller', :index, 'storages'

  def generate_csv_upload(name)
    ActionDispatch::Http::UploadedFile.new(
      tempfile: File.new(Rails.root.join('spec', 'fixtures', name)),
      filename: File.basename(name),
      type: 'text/csv'
    )
  end

  # describe 'GET index' do
  #   login_user
  #
  #   before(:each) do
  #     create :storage
  #     get(:index)
  #   end
  #
  #   it 'populates an array of uploads' do
  #     expect(assigns(:storages)).to include(Storage.first)
  #   end
  #
  #   it 'returns http success' do
  #     expect(response).to have_http_status(:success)
  #   end
  # end
  #
  # describe 'GET download' do
  #   login_user
  #
  #   let(:storage) { create :storage }
  #
  #   context 'with a valid id' do
  #     before(:each) do
  #       get(:download, params:{id: storage.id})
  #     end
  #
  #     it 'gets the storage' do
  #       expect(assigns(:storage)).to eq(storage)
  #     end
  #   end
  #
  #   context 'with an invalid id' do
  #     it 'generates an alert message' do
  #       get(:download, params:{id: 1_000_000})
  #       expect(flash[:alert]).to match 'Invalid Storage id: 1000000'
  #     end
  #   end
  # end
  #
  # describe 'GET show' do
  #   login_user
  #
  #   let(:storage) { create :storage }
  #
  #   context 'with a valid id' do
  #     before(:each) do
  #       get(:show, params:{id: storage.id})
  #     end
  #
  #     it 'gets the storage' do
  #       expect(assigns(:storage)).to eq(storage)
  #       expect(response).to have_http_status(:success)
  #     end
  #   end
  #
  #   context 'with an invalid id' do
  #     it 'generates an alert message' do
  #       get(:show, params:{id: 1_000_000})
  #       expect(flash[:alert]).to match 'Invalid Storage id: 1000000'
  #     end
  #
  #     it 'redirects to the index action' do
  #       expect(get(:show, params:{id: 1_000_000})).to redirect_to(action: :index)
  #     end
  #   end
  # end
  #
  # describe 'GET edit' do
  #   login_user
  #
  #   context 'specifying a valid' do
  #     before(:each) do
  #       create :storage
  #       get(:edit, params:{id: storage.id})
  #     end
  #
  #     let(:storage) { Storage.first }
  #
  #     context 'with a valid id' do
  #       it 'assigns storage and returns success' do
  #         expect(assigns(:storage)).to eq(storage)
  #         expect(response).to have_http_status(:success)
  #       end
  #     end
  #
  #     context 'with an invalid id' do
  #       it 'redirects to the index action' do
  #         expect(get(:edit, params:{id: 1_000_000})).to redirect_to(action: :index)
  #       end
  #
  #       it 'generates an alert message' do
  #         get(:edit, params:{id: 1_000_000})
  #         expect(flash[:alert]).to match 'Invalid Storage id: 1000000'
  #       end
  #     end
  #   end
  # end

  describe 'PUT update' do
    login_user

    context 'with a valid id' do
      before(:each) do
        create :storage
      end

      let(:old) { Storage.first }
      let(:upload_file) { generate_csv_upload('weam_extra_column.csv') }
      let(:params) { { id: old.id, upload_file: upload_file } }
      let(:new_data) { File.read(params[:upload_file].path, encoding: 'ISO-8859-1') }

      context 'with a valid id' do
        it 'replaces the existing data' do
          put(:update, params:{id: params.delete(:id), storage: params})
          binding.pry()
          expect(Storage.first.data).to eq(new_data)
        end
      end

      # context 'with an invalid id' do
      #   it 'redirects to the index action' do
      #     expect(put(:update, id: 1_000_000, storage: params)).to redirect_to(action: :index)
      #   end
      #
      #   it 'generates an alert message' do
      #     put(:update, params:{id: 1_000_000, storage: params})
      #     expect(flash[:alert]).to match 'Invalid Storage id: 1000000'
      #   end
      # end
      #
      # context 'with invalid parameters' do
      #   it 'renders to the edit template' do
      #     params[:upload_file] = nil
      #     expect(put(:update, id: params.delete(:id), storage: params)).to render_template(:edit)
      #   end
      # end
    end
  end
end
