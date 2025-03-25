# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'V1::Lcpe::Exam', type: :request do
  let(:version) { create(:version, :production) }
  let(:institution) { create(:institution, version_id: version.id) }
  let(:exam) { Lcpe::Exam.last }
  let(:preload) { Lcpe::PreloadDataset.fresh('Lcpe::Exam') }
  let(:enriched_id) { "#{exam.id}v#{preload.id}" }
  let(:fresh_etag) { "W/\"#{preload.id}\"" }
  let(:stale_etag) { "W/\"#{preload.id - 1}\""}

  before do
    create(:weam, facility_code: institution.facility_code)
    create(:lcpe_exam, facility_code: institution.facility_code)
    Lcpe::PreloadDataset.build('Lcpe::Exam')
  end

  describe 'GET /index' do
    context 'when versioning enabled (filter params absent)' do
      context 'when client version fresh' do
        let(:client_etag) { fresh_etag }

        it 'returns http not modified' do
          get '/v1/lcpe/exams', headers: { 'If-None-Match' => client_etag }
          expect(response).to have_http_status(:not_modified)
          expect(response.headers['Etag']).to eq(client_etag)
        end
      end

      context 'when client version stale' do
        let(:client_etag) { stale_etag }

        it 'returns http success' do
          get '/v1/lcpe/exams', headers: { 'If-None-Match' => client_etag }
          expect(response).to have_http_status(:success)
          expect(response.headers['Etag']).to eq(fresh_etag)
          parsed_exam = JSON.parse(response.body)['exams'].first
          expect(parsed_exam).to include(
            'name' => exam.nexam_nm,
            'enriched_id' => enriched_id,
          )
        end
      end

      context 'when client version nil' do
        let(:client_etag) { nil }

        it 'returns http success' do
          get '/v1/lcpe/exams', headers: { 'If-None-Match' => client_etag }
          expect(response).to have_http_status(:success)
          expect(response.headers['Etag']).to eq(fresh_etag)
          parsed_exam = JSON.parse(response.body)['exams'].first
          expect(parsed_exam).to include(
            'name' => exam.nexam_nm,
            'enriched_id' => enriched_id,
          )
        end
      end
    end
  end

  describe 'GET /show' do
    context 'when version valid' do
      let!(:exam_test) { create(:lcpe_exam_test, exam_id: exam.id )}
      let(:test_hash) { serialize_nested_hash(Lcpe::ExamTestSerializer.new(exam_test)) }
      let(:inst_hash) { serialize_nested_hash(Lcpe::InstitutionSerializer.new(institution)) }
  
      it 'returns http success' do
        get "/v1/lcpe/exams/#{enriched_id}"
        expect(response).to have_http_status(:success)
        parsed_exam = JSON.parse(response.body)['exam']
        expect(parsed_exam).to include(
          'enriched_id' => enriched_id,
          'name' => exam.nexam_nm
        )
        expect(parsed_exam['institution']).to include(inst_hash)
        expect(parsed_exam['tests'].first).to include(test_hash)
      end
    end

    context 'when version invalid' do
      let(:enriched_id) { "#{exam.id}v#{preload.id - 1}" }

      it 'returns http conflict' do
        get "/v1/lcpe/exams/#{enriched_id}"
        expect(response).to have_http_status(:conflict)
      end
    end
  end

  def serialize_nested_hash(serializer)
    serializer.serializable_hash.deep_transform_keys(&:to_s)
  end
end
