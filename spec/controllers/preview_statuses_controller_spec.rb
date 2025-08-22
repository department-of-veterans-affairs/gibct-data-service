# frozen_string_literal: true

require 'rails_helper'
require 'support/controller_macros'
require 'support/devise'
require 'controllers/shared_examples/shared_examples_for_authentication'

RSpec.describe PreviewStatusesController, type: :controller do
  before { request.headers["Accept"] = Mime[:turbo_stream].to_s }
  
  describe 'GET poll' do
    login_user

    context 'preview generation not started' do
      it 'returns no content header if no preview stauses present' do
        get :poll
        expect(response).to have_http_status(:no_content)
      end
    end

    context 'preview generation started but incomplete' do
      it 'sets preview status value and completed to false' do
        pgsi = create(:preview_generation_status_information)
        get :poll
        expect(response).to have_http_status(:success)
        expect(assigns(:preview_status)).to eq(pgsi)
        expect(assigns(:preview_generation_completed)).to eq(false)
      end
    end

    shared_examples 'completed preview generation' do
      it 'sets preview status value and completed to true' do
        expect(response).to have_http_status(:success)
        expect(assigns(:preview_status)).to eq(pgsi)
        expect(assigns(:preview_generation_completed)).to eq(true)
      end

      it 'deletes all preview generation status informations' do
        expect(PreviewGenerationStatusInformation.exists?).to eq(false)
      end

      it 'queues PerformInstitutionTablesMaintenanceJob' do
        expect(PerformInstitutionTablesMaintenanceJob).to have_received(:perform_later)
      end
    end

    context 'preview generation completes successfully' do
      let!(:pgsi) { create(:preview_generation_status_information, :complete) }
      
      before do
        allow(PerformInstitutionTablesMaintenanceJob).to receive(:perform_later)
        get :poll
      end

      it_behaves_like "completed preview generation"
    end

    context 'preview generation ends in error' do
      let!(:pgsi) { create(:preview_generation_status_information, :complete_error) }

      before do
        allow(PerformInstitutionTablesMaintenanceJob).to receive(:perform_later)
        get :poll
      end

      it_behaves_like "completed preview generation"
    end
  end
end