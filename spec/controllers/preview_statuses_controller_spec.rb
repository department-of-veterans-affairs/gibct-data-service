# frozen_string_literal: true

require 'rails_helper'
require 'support/controller_macros'
require 'support/devise'
require 'controllers/shared_examples/shared_examples_for_authentication'

RSpec.describe PreviewStatusesController, type: :controller do
  before { request.headers['Accept'] = Mime[:turbo_stream].to_s }

  describe 'GET poll' do
    login_user

    context 'when preview generation not started' do
      it 'returns no content header if no preview stauses present' do
        get :poll
        expect(response).to have_http_status(:no_content)
      end
    end

    context 'when preview generation started but incomplete' do
      it 'sets preview status value and completed to false' do
        pgsi = create(:preview_generation_status_information)
        get :poll
        expect(response).to have_http_status(:success)
        expect(assigns(:preview_status)).to eq(pgsi)
        expect(assigns(:preview_generation_completed)).to eq(false)
      end
    end

    shared_examples 'completed preview generation' do |trait|
      let!(:pgsi) { create(:preview_generation_status_information, trait) }

      before do
        allow(InstitutionTablesMaintenanceJob).to receive(:perform_later)
        get :poll
      end

      it 'sets preview status value and completed to true' do
        expect(response).to have_http_status(:success)
        expect(assigns(:preview_status)).to eq(pgsi)
        expect(assigns(:preview_generation_completed)).to eq(true)
      end

      it 'deletes all preview generation status informations' do
        expect(PreviewGenerationStatusInformation.exists?).to eq(false)
      end

      it 'queues InstitutionTablesMaintenanceJob' do
        expect(InstitutionTablesMaintenanceJob).to have_received(:perform_later)
      end
    end

    context 'when preview generation completes successfully' do
      it_behaves_like 'completed preview generation', :complete
    end

    context 'when preview generation ends in error' do
      it_behaves_like 'completed preview generation', :complete_error
    end
  end
end
