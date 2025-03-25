# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'V1::Lcpe::Lac', type: :request do
  let(:version) { create(:version, :production) }
  let(:institution) { create(:institution, version_id: version.id) }
  let(:lac) { Lcpe::Lac.last }
  let(:preload) { Lcpe::PreloadDataset.fresh('Lcpe::Lac') }
  let(:enriched_id) { "#{lac.id}v#{preload.id}" }
  let(:fresh_etag) { "W/\"#{preload.id}\"" }
  let(:stale_etag) { "W/\"#{preload.id - 1}\""}

  before do
    create(:weam, facility_code: institution.facility_code)
    create(:lcpe_lac, facility_code: institution.facility_code)
    Lcpe::PreloadDataset.build('Lcpe::Lac')
  end

  describe 'GET /index' do
    context 'when versioning enabled (filter params absent)' do
      context 'when client version fresh' do
        let(:client_etag) { fresh_etag }

        it 'returns http not modified' do
          get '/v1/lcpe/lacs', headers: { 'If-None-Match' => client_etag }
          expect(response).to have_http_status(:not_modified)
          expect(response.headers['Etag']).to eq(client_etag)
        end
      end

      context 'when client version stale' do
        let(:client_etag) { stale_etag }

        it 'returns http success' do
          get '/v1/lcpe/lacs', headers: { 'If-None-Match' => client_etag }
          expect(response).to have_http_status(:success)
          expect(response.headers['Etag']).to eq(fresh_etag)
          parsed_lac = JSON.parse(response.body)['lacs'].first
          expect(parsed_lac).to include(
            'edu_lac_type_nm' => lac.edu_lac_type_nm,
            'enriched_id' => enriched_id,
            'lac_nm' => lac.lac_nm,
            'state' => lac.state
          )
        end
      end

      context 'when client version nil' do
        let(:client_etag) { nil }

        it 'returns http success' do
          get '/v1/lcpe/lacs', headers: { 'If-None-Match' => client_etag }
          expect(response).to have_http_status(:success)
          expect(response.headers['Etag']).to eq(fresh_etag)
          parsed_lac = JSON.parse(response.body)['lacs'].first
          expect(parsed_lac).to include(
            'edu_lac_type_nm' => lac.edu_lac_type_nm,
            'enriched_id' => enriched_id,
            'lac_nm' => lac.lac_nm,
            'state' => lac.state
          )
        end
      end
    end

    context 'when versioning disabled (filter params present)' do
      let!(:lac_by_state) { create(:lcpe_lac, state: 'MT', facility_code: institution.facility_code) }
      let(:enriched_id) { "#{lac_by_state.id}v#{preload.id}" }

      it 'returns http success' do
        get '/v1/lcpe/lacs', params: { state: lac_by_state.state }
        expect(response).to have_http_status(:success)
        parsed_lacs = JSON.parse(response.body)['lacs']
        expect(parsed_lacs.size).to eq(1)
        expect(parsed_lacs.first).to include(
          'edu_lac_type_nm' => lac_by_state.edu_lac_type_nm,
          'enriched_id' => enriched_id,
          'lac_nm' => lac_by_state.lac_nm,
          'state' => lac_by_state.state
        )
      end


      context 'when pagination enabled' do
        it 'paginates results' do
          get '/v1/lcpe/lacs', params: { per_page: 1 }
          expect(response).to have_http_status(:success)
          parsed = JSON.parse(response.body)
          expect(parsed['lacs'].size).to eq(1)
          expect(parsed['meta']).to include(
            'current_page' => 1,
            'next_page' => 2,
            'prev_page' => nil,
            'total_count' => 2
          )
        end
      end
    end
  end

  describe 'GET /show' do
    context 'when version valid' do
      let!(:lac_test) { create(:lcpe_lac_test, lac_id: lac.id )}
      let(:test_hash) { serialize_nested_hash(Lcpe::LacTestSerializer.new(lac_test)) }
      let(:inst_hash) { serialize_nested_hash(Lcpe::InstitutionSerializer.new(institution)) }
  
      it 'returns http success' do
        get "/v1/lcpe/lacs/#{enriched_id}"
        expect(response).to have_http_status(:success)
        parsed_lac = JSON.parse(response.body)['lac']
        expect(parsed_lac).to include(
          'edu_lac_type_nm' => lac.edu_lac_type_nm,
          'enriched_id' => enriched_id,
          'lac_nm' => lac.lac_nm,
          'state' => lac.state,
        )
        expect(parsed_lac['institution']).to include(inst_hash)
        expect(parsed_lac['tests'].first).to include(test_hash)
      end
    end

    context 'when version invalid' do
      let(:enriched_id) { "#{lac.id}v#{preload.id - 1}" }

      it 'returns http conflict' do
        get "/v1/lcpe/lacs/#{enriched_id}"
        expect(response).to have_http_status(:conflict)
      end
    end
  end

  def serialize_nested_hash(serializer)
    serializer.serializable_hash.deep_transform_keys(&:to_s)
  end
end
