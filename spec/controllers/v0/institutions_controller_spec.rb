# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V0::InstitutionsController, type: :controller do
  def expect_response_match_schema(schema)
    expect(response.content_type).to eq('application/json')
    expect(response).to match_response_schema(schema)
  end

  def expect_meta_body_eq_preview(body, version_preview_number)
    expect(body['meta']['version']['number'].to_i).to eq(version_preview_number)
  end

  def create_extension_institutions(trait)
    create(:institution, trait, campus_type: 'E')
    create(:institution, trait, campus_type: 'Y')
    create(:institution, trait)
  end

  describe 'version determination' do
    it 'uses a production version as a default' do
      create(:version, :production)
      create(:institution, :contains_harv)
      get(:index)
      expect_response_match_schema('institutions')
    end

    def preview_body(body)
      JSON.parse(body)
    end

    it 'accepts invalid version parameter and returns production data' do
      create(:version, :production)
      create(:institution, :contains_harv)
      get(:index, params: { version: 'invalid_data' })
      expect_response_match_schema('institutions')
      expect_meta_body_eq_preview(preview_body(response.body), Version.current_production.number)
    end

    it 'accepts version number as a version parameter and returns preview data' do
      v = create(:version, :preview)
      create(:institution, :contains_harv, version: Version.current_preview.number)
      get(:index, params: { version: v.uuid })
      expect_response_match_schema('institutions')
      expect_meta_body_eq_preview(preview_body(response.body), Version.current_preview.number)
    end
  end

  describe '#autocomplete' do
    it 'returns collection of matches' do
      create(:version, :production)
      create_list(:institution, 2, :start_like_harv)
      get(:autocomplete, params: { term: 'harv' })
      expect(JSON.parse(response.body)['data'].count).to eq(2)
      expect_response_match_schema('autocomplete')
    end

    it 'limits results to 6' do
      create(:version, :production)
      create_list(:institution, 7, :start_like_harv, approved: true)
      get(:autocomplete, params: { term: 'harv' })
      expect(JSON.parse(response.body)['data'].count).to eq(6)
      expect_response_match_schema('autocomplete')
    end

    it 'returns empty collection on missing term parameter' do
      create(:version, :production)
      create(:institution, :start_like_harv)
      get(:autocomplete)
      expect(JSON.parse(response.body)['data'].count).to eq(0)
      expect_response_match_schema('autocomplete')
    end

    it 'does not return results for non-approved institutions' do
      create(:version, :production)
      create(:institution, :start_like_harv, approved: false)
      get(:autocomplete, params: { term: 'harv' })
      expect(JSON.parse(response.body)['data'].count).to eq(0)
      expect_response_match_schema('autocomplete')
    end

    it 'does not return results for extension institutions' do
      create(:version, :production)
      create_extension_institutions(:start_like_harv)
      get(:autocomplete, params: { term: 'harv' })
      expect(JSON.parse(response.body)['data'].count).to eq(2)
      expect_response_match_schema('autocomplete')
    end
  end

  describe '#index (search)' do
    def create_facets_keys_array(facets)
      [
        facets['student_vet_group'].keys,
        facets['yellow_ribbon_scholarship'].keys,
        facets['principles_of_excellence'].keys,
        facets['eight_keys_to_veteran_success'].keys,
        facets['stem_offered'].keys,
        facets['independent_study'].keys,
        facets['priority_enrollment'].keys,
        facets['online_only'].keys,
        facets['distance_learning'].keys
      ]
    end

    def check_boolean_facets(facets)
      facet_keys = create_facets_keys_array(facets)
      expect(facet_keys).to RSpec::Matchers::BuiltIn::All.new(include('true', 'false'))
    end

    before do
      create(:version, :production)
      create_list(:institution, 2, :in_nyc)
      create(:institution, :in_chicago, online_only: true)
      create(:institution, :in_new_rochelle, distance_learning: true)
      # adding a non approved institutions row
      create(:institution, :contains_harv, approved: false)
    end

    it 'returns results' do
      get(:index)
      expect(JSON.parse(response.body)['data'].count).to eq(4)
      expect_response_match_schema('institutions')
    end

    it 'returns results matching name' do
      get(:index, params: { name: 'chicago' })
      expect(JSON.parse(response.body)['data'].count).to eq(1)
      expect_response_match_schema('institutions')
    end

    it 'returns case-insensitive results' do
      get(:index, params: { name: 'CHICAGO' })
      expect(JSON.parse(response.body)['data'].count).to eq(1)
      expect_response_match_schema('institutions')
    end

    context 'with space in search parameter' do
      it 'returns results' do
        get(:index, params: { name: 'New Roch' })
        expect(JSON.parse(response.body)['data'].count).to eq(1)
        expect_response_match_schema('institutions')
      end
    end

    it 'does not return extension institutions in results' do
      create_extension_institutions(:contains_harv)
      get(:index, params: { name: 'harv' })
      expect(JSON.parse(response.body)['data'].count).to eq(2)
      expect_response_match_schema('institutions')
    end

    context 'with an uppercase country filter' do
      it 'returns filtered results' do
        get(:index, params: { name: 'chicago', country: 'USA' })
        expect(JSON.parse(response.body)['data'].count).to eq(1)
        expect_response_match_schema('institutions')
      end
    end

    context 'with a lowecase country filter' do
      it 'returns filtered results' do
        get(:index, params: { name: 'chicago', country: 'usa' })
        expect(JSON.parse(response.body)['data'].count).to eq(1)
        expect_response_match_schema('institutions')
      end
    end

    context 'with an uppercase state filter' do
      it 'returns filtered results' do
        get(:index, params: { name: 'new', state: 'NY' })
        expect(JSON.parse(response.body)['data'].count).to eq(3)
        expect_response_match_schema('institutions')
      end
    end

    context 'with an `online_only` filter' do
      it 'returns filtered results' do
        get(:index, params: { online_only: true })
        expect(JSON.parse(response.body)['data'].count).to eq(1)
      end
    end

    context 'with a `distance_learning` filter' do
      it 'returns filtered results' do
        get(:index, params: { distance_learning: true })
        expect(JSON.parse(response.body)['data'].count).to eq(1)
      end
    end

    context 'with a `vet_tec_provider` filter' do
      it 'returns filtered results' do
        create(:institution, :vet_tec_provider)
        create(:institution, :vet_tec_provider, vet_tec_provider: false)
        get(:index, params: { vet_tec_provider: true })
        expect(JSON.parse(response.body)['data'].count).to eq(1)
      end
    end

    context 'with a `preferred_provider` filter' do
      it 'returns filtered results' do
        create(:institution, :vet_tec_provider)
        create(:institution, :vet_tec_preferred_provider)
        get(:index, params: { vet_tec_provider: true, preferred_provider: true })
        expect(JSON.parse(response.body)['data'].count).to eq(1)
      end
    end

    context 'with a lowercase `state` filter' do
      it 'returns filtered results' do
        get(:index, params: { name: 'new', state: 'ny' })
        expect(JSON.parse(response.body)['data'].count).to eq(3)
        expect_response_match_schema('institutions')
      end
    end

    it 'includes facet metadata' do
      get(:index, params: { name: 'chicago' })
      facets = JSON.parse(response.body)['meta']['facets']
      expect(facets['state']['il']).to eq(1)
      expect(facets['country'].count).to eq(1)
      expect(facets['country'][0]['name']).to eq('USA')
    end

    it 'includes type search term in facets' do
      get(:index, params: { name: 'chicago', type: 'foreign' })
      facets = JSON.parse(response.body)['meta']['facets']
      expect(facets['type']['foreign']).not_to be_nil
      expect(facets['type']['foreign']).to eq(0)
    end

    it 'includes state search term in facets' do
      get(:index, params: { name: 'chicago', state: 'WY' })
      facets = JSON.parse(response.body)['meta']['facets']
      expect(facets['state']['wy']).not_to be_nil
      expect(facets['state']['wy']).to eq(0)
    end

    it 'includes country search term in facets' do
      get(:index, params: { name: 'chicago', country: 'france' })
      facets = JSON.parse(response.body)['meta']['facets']
      match = facets['country'].select { |c| c['name'] == 'FRANCE' }.first
      expect(match).not_to be nil
      expect(match['count']).to eq(0)
    end

    it 'includes boolean facets' do
      get(:index)
      facets = JSON.parse(response.body)['meta']['facets']
      check_boolean_facets(facets)
    end

    context 'with a `category` filter' do
      before do
        create(:institution, :ca_employer)
      end

      context 'with a category of "employer"' do
        it 'returns employers in the results' do
          get(:index, params: { category: 'employer' })
          expect(JSON.parse(response.body)['data'].count).to eq(1)
          expect_response_match_schema('institutions')
        end
      end

      context 'with a category of "school"' do
        it 'returns schools in the results' do
          get(:index, params: { category: 'school' })
          expect(JSON.parse(response.body)['data'].count).to eq(4)
          expect_response_match_schema('institutions')
        end
      end
    end

    context 'with a `type` filter' do
      before do
        create(:institution, :ca_employer)
      end

      context 'with a type of "ojt"' do
        it 'returns employers in results' do
          get(:index, params: { type: 'ojt' })
          expect(JSON.parse(response.body)['data'].count).to eq(1)
          expect_response_match_schema('institutions')
        end
      end

      context 'with a type of "private"' do
        it 'returns private institutions in results' do
          get(:index, params: { type: 'private' })
          expect(JSON.parse(response.body)['data'].count).to eq(4)
          expect_response_match_schema('institutions')
        end
      end
    end
  end

  describe '#show' do
    before do
      create(:version, :production)
    end

    it 'returns profile details' do
      school = create(:institution, :in_chicago)
      get(:show, params: { id: school.facility_code, version: school.version })
      expect_response_match_schema('institution_profile')
    end

    it 'returns common exception response if school not found' do
      get(:show, params: { id: '10000' })
      assert_response :missing
      expect_response_match_schema('errors')
    end
  end

  describe '#children' do
    before do
      create(:version, :production)
    end

    context 'with an ID of a school that has "children"' do
      let!(:school) { create(:institution, :in_chicago) }
      let!(:child_school) { create(:institution, :in_chicago, parent_facility_code_id: school.facility_code) }

      it 'returns institution children' do
        get(:children, params: { id: school.facility_code, version: school.version })
        expect(JSON.parse(response.body)['data'].count).to eq(1)
        expect(JSON.parse(response.body)['data'][0]['attributes']['facility_code']).to eq(child_school.facility_code)
        expect(JSON.parse(response.body)['data'][0]['attributes']['parent_facility_code_id']).to eq(school.facility_code)
        expect_response_match_schema('institutions')
      end
    end

    context 'with an invalid ID' do
      it 'returns empty record set' do
        get(:children, params: { id: '10000' })
        expect(response.content_type).to eq('application/json')
        expect(JSON.parse(response.body)['data'].count).to eq(0)
      end
    end
  end
end
