# frozen_string_literal: true

require 'rails_helper'
require 'support/controller_macros'
require 'support/devise'

RSpec.describe LatitudeLongitudeIssuesController, type: :controller do
  describe 'GET export' do
    login_user

    it 'causes a CSV to be exported' do
      allow(CensusLatLong).to receive(:export)
      get(:export)
      expect(CensusLatLong).to have_received(:export)
    end

    it 'includes filename parameter in content-disposition header' do
      allow(CensusLatLong).to receive(:export)
      get(:export)
      expect(response.headers['Content-Disposition']).to include('filename="CensusLatLong.zip"')
    end

    it 'displays error' do
      allow(CensusLatLong).to receive(:export).and_raise(StandardError, 'BOOM!')
      get(:export)
      expect(flash[:alert]).to be_present
      expect(flash[:alert]).to match 'BOOM!'
    end
  end

  describe 'import' do
    login_user

    it 'is not implemented' do
      get(:import)
      expect(flash[:alert]).to match 'Not implemented'
    end
  end
end
