# frozen_string_literal: true
require 'rails_helper'
require 'support/controller_macros'
require 'support/devise'

RSpec.describe 'Dashboard', type: :request do
  before(:each) do
    user = User.create!(email: 'testuser@va.gov', password: 'secretshh')
    login_as(user, scope: :user)
  end

  let(:storage) { create :storage }
  let(:data) { File.open(storage.upload_file.path).read }

  it 'GET storages/:id/download downloads storage data' do
    get download_storage_path(storage.id)
    expect(response.body).to eq(data)
  end
end
