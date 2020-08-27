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

  context 'with version determination' do
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
      expect(response.content_type).to eq('application/json')
      expect(response).to match_response_schema('institutions')
      body = JSON.parse response.body
      expect(body['meta']['version']['number'].to_i).to eq(Version.current_production.number)
    end

    it 'accepts version number as a version parameter and returns preview data' do
      create(:version, :production)
      v = create(:version, :preview)
      create(:institution, :contains_harv, :production_version)
      get(:index, params: { version: v.uuid })
      expect(response.content_type).to eq('application/json')
      expect(response).to match_response_schema('institutions')
      body = JSON.parse response.body
      expect(body['meta']['version']['number'].to_i).to eq(Version.current_preview.number)
    end
  end

  context 'with autocomplete results' do
    before do
      create(:version, :production)
    end

    it 'returns collection of matches' do
      create_list(:institution, 2, :start_like_harv, :production_version)
      get(:autocomplete, params: { term: 'harv' })
      expect(JSON.parse(response.body)['data'].count).to eq(2)
      expect(response.content_type).to eq('application/json')
      expect(response).to match_response_schema('autocomplete')
    end

    it 'limits results to 6' do
      create_list(:institution, 7, :start_like_harv, :production_version, approved: true)
      get(:autocomplete, params: { term: 'harv' })
      expect(JSON.parse(response.body)['data'].count).to eq(6)
      expect(response.content_type).to eq('application/json')
      expect(response).to match_response_schema('autocomplete')
    end

    it 'returns empty collection on missing term parameter' do
      create(:institution, :start_like_harv)
      get(:autocomplete)
      expect(JSON.parse(response.body)['data'].count).to eq(0)
      expect(response.content_type).to eq('application/json')
      expect(response).to match_response_schema('autocomplete')
    end

    it 'does not return results for non-approved institutions' do
      create(:institution, :start_like_harv, approved: false)
      get(:autocomplete, params: { term: 'harv' })
      expect(JSON.parse(response.body)['data'].count).to eq(0)
      expect(response.content_type).to eq('application/json')
      expect(response).to match_response_schema('autocomplete')
    end

    it 'does not return results for extension institutions' do
      create(:institution, :start_like_harv, :production_version, campus_type: 'E')
      create(:institution, :start_like_harv, :production_version, campus_type: 'Y')
      create(:institution, :start_like_harv, :production_version)
      get(:autocomplete, params: { term: 'harv' })
      expect(JSON.parse(response.body)['data'].count).to eq(2)
      expect(response.content_type).to eq('application/json')
      expect(response).to match_response_schema('autocomplete')
    end

    it 'excludes vet_tec_provider institutions' do
      create(:institution, :vet_tec_provider, :start_like_harv)
      get(:autocomplete, params: { term: 'harv' })
      expect(JSON.parse(response.body)['data'].count).to eq(0)
      expect(response.content_type).to eq('application/json')
      expect(response).to match_response_schema('autocomplete')
    end

    it 'excludes institutions with caution flags' do
      institution = create(:institution, :start_like_harv, :production_version)
      create(:institution, :exclude_caution_flags, :start_like_harv, :production_version)
      get(:autocomplete, params: { term: 'harv', exclude_caution_flags: true })
      expect(JSON.parse(response.body)['data'].count).to eq(1)
      expect(JSON.parse(response.body)['data'][0]['id']).to eq(institution.id)
      expect(response.content_type).to eq('application/json')
      expect(response).to match_response_schema('autocomplete')
    end

    it 'excludes institutions with school closing flag' do
      institution = create(:institution, :start_like_harv, :production_version)
      create(:institution, :exclude_school_closing, :start_like_harv, :production_version)
      get(:autocomplete, params: { term: 'harv', exclude_warnings: true })
      expect(JSON.parse(response.body)['data'].count).to eq(1)
      expect(JSON.parse(response.body)['data'][0]['id']).to eq(institution.id)
      expect(response.content_type).to eq('application/json')
      expect(response).to match_response_schema('autocomplete')
    end

    it 'filters by type' do
      institution = create(:institution, :start_like_harv, :production_version)
      create(:institution, :start_like_harv, :production_version, institution_type_name: 'PUBLIC')
      get(:autocomplete, params: { term: 'harv', type: 'private' })
      expect(JSON.parse(response.body)['data'].count).to eq(1)
      expect(JSON.parse(response.body)['data'][0]['id']).to eq(institution.id)
      expect(response.content_type).to eq('application/json')
      expect(response).to match_response_schema('autocomplete')
    end

    it 'filters by category' do
      institution = create(:institution, :start_like_harv, :production_version)
      create(:institution, :start_like_harv, :production_version, institution_type_name: Institution::EMPLOYER)
      get(:autocomplete, params: { term: 'harv', category: 'school' })
      expect(JSON.parse(response.body)['data'].count).to eq(1)
      expect(JSON.parse(response.body)['data'][0]['id']).to eq(institution.id)
      expect(response.content_type).to eq('application/json')
      expect(response).to match_response_schema('autocomplete')
    end

    it 'filters by country' do
      institution = create(:institution, :start_like_harv, :production_version)
      create(:institution, :start_like_harv, :production_version, country: 'CAN')
      get(:autocomplete, params: { term: 'harv', country: 'usa' })
      expect(JSON.parse(response.body)['data'].count).to eq(1)
      expect(JSON.parse(response.body)['data'][0]['id']).to eq(institution.id)
      expect(response.content_type).to eq('application/json')
      expect(response).to match_response_schema('autocomplete')
    end

    it 'filters by state' do
      institution = create(:institution, :start_like_harv, :production_version)
      create(:institution, :start_like_harv, :production_version, state: 'MD')
      get(:autocomplete, params: { term: 'harv', state: 'ma' })
      expect(JSON.parse(response.body)['data'].count).to eq(1)
      expect(JSON.parse(response.body)['data'][0]['id']).to eq(institution.id)
      expect(response.content_type).to eq('application/json')
      expect(response).to match_response_schema('autocomplete')
    end

    it 'filters by student_veteran_group' do
      institution = create(:institution, :start_like_harv, :production_version, student_veteran: 'true')
      create(:institution, :start_like_harv, :production_version)
      get(:autocomplete, params: { term: 'harv', student_veteran_group: true })
      expect(JSON.parse(response.body)['data'].count).to eq(1)
      expect(JSON.parse(response.body)['data'][0]['id']).to eq(institution.id)
      expect(response.content_type).to eq('application/json')
      expect(response).to match_response_schema('autocomplete')
    end

    it 'filters by yellow_ribbon_scholarship' do
      institution = create(:institution, :start_like_harv, :production_version, yr: 'true')
      create(:institution, :start_like_harv, :production_version)
      get(:autocomplete, params: { term: 'harv', yellow_ribbon_scholarship: true })
      expect(JSON.parse(response.body)['data'].count).to eq(1)
      expect(JSON.parse(response.body)['data'][0]['id']).to eq(institution.id)
      expect(response.content_type).to eq('application/json')
      expect(response).to match_response_schema('autocomplete')
    end

    it 'filters by principles_of_excellence' do
      institution = create(:institution, :start_like_harv, :production_version, poe: 'true')
      create(:institution, :start_like_harv, :production_version)
      get(:autocomplete, params: { term: 'harv', principles_of_excellence: true })
      expect(JSON.parse(response.body)['data'].count).to eq(1)
      expect(JSON.parse(response.body)['data'][0]['id']).to eq(institution.id)
      expect(response.content_type).to eq('application/json')
      expect(response).to match_response_schema('autocomplete')
    end

    it 'filters by eight_keys_to_veteran_success' do
      institution = create(:institution, :start_like_harv, :production_version, eight_keys: 'true')
      create(:institution, :start_like_harv, :production_version)
      get(:autocomplete, params: { term: 'harv', eight_keys_to_veteran_success: true })
      expect(JSON.parse(response.body)['data'].count).to eq(1)
      expect(JSON.parse(response.body)['data'][0]['id']).to eq(institution.id)
      expect(response.content_type).to eq('application/json')
      expect(response).to match_response_schema('autocomplete')
    end

    it 'filters by stem_offered' do
      institution = create(:institution, :start_like_harv, :production_version, stem_offered: 'true')
      create(:institution, :start_like_harv, :production_version)
      get(:autocomplete, params: { term: 'harv', stem_offered: true })
      expect(JSON.parse(response.body)['data'].count).to eq(1)
      expect(JSON.parse(response.body)['data'][0]['id']).to eq(institution.id)
      expect(response.content_type).to eq('application/json')
      expect(response).to match_response_schema('autocomplete')
    end

    it 'filters by independent_study' do
      institution = create(:institution, :start_like_harv, :production_version, independent_study: 'true')
      create(:institution, :start_like_harv, :production_version)
      get(:autocomplete, params: { term: 'harv', independent_study: true })
      expect(JSON.parse(response.body)['data'].count).to eq(1)
      expect(JSON.parse(response.body)['data'][0]['id']).to eq(institution.id)
      expect(response.content_type).to eq('application/json')
      expect(response).to match_response_schema('autocomplete')
    end

    it 'filters by online_only' do
      institution = create(:institution, :start_like_harv, :production_version, online_only: 'true')
      create(:institution, :start_like_harv, :production_version)
      get(:autocomplete, params: { term: 'harv', online_only: true })
      expect(JSON.parse(response.body)['data'].count).to eq(1)
      expect(JSON.parse(response.body)['data'][0]['id']).to eq(institution.id)
      expect(response.content_type).to eq('application/json')
      expect(response).to match_response_schema('autocomplete')
    end

    it 'filters by distance_learning' do
      institution = create(:institution, :start_like_harv, :production_version, distance_learning: 'true')
      create(:institution, :start_like_harv, :production_version)
      get(:autocomplete, params: { term: 'harv', distance_learning: true })
      expect(JSON.parse(response.body)['data'].count).to eq(1)
      expect(JSON.parse(response.body)['data'][0]['id']).to eq(institution.id)
      expect(response.content_type).to eq('application/json')
      expect(response).to match_response_schema('autocomplete')
    end

    it 'filters by priority_enrollment' do
      institution = create(:institution, :start_like_harv, :production_version, priority_enrollment: 'true')
      create(:institution, :start_like_harv, :production_version)
      get(:autocomplete, params: { term: 'harv', priority_enrollment: true })
      expect(JSON.parse(response.body)['data'].count).to eq(1)
      expect(JSON.parse(response.body)['data'][0]['id']).to eq(institution.id)
      expect(response.content_type).to eq('application/json')
      expect(response).to match_response_schema('autocomplete')
    end

    it 'filters by preferred_provider' do
      institution = create(:institution, :start_like_harv, :production_version, preferred_provider: 'true')
      create(:institution, :start_like_harv, :production_version)
      get(:autocomplete, params: { term: 'harv', preferred_provider: true })
      expect(JSON.parse(response.body)['data'].count).to eq(1)
      expect(JSON.parse(response.body)['data'][0]['id']).to eq(institution.id)
      expect(response.content_type).to eq('application/json')
      expect(response).to match_response_schema('autocomplete')
    end

    it 'filters by stem_indicator' do
      institution = create(:institution, :start_like_harv, :production_version, stem_indicator: 'true')
      create(:institution, :start_like_harv, :production_version)
      get(:autocomplete, params: { term: 'harv', stem_indicator: true })
      expect(JSON.parse(response.body)['data'].count).to eq(1)
      expect(JSON.parse(response.body)['data'][0]['id']).to eq(institution.id)
      expect(response.content_type).to eq('application/json')
      expect(response).to match_response_schema('autocomplete')
    end
  end

  context 'with search results' do
    # need to separate methods in order to pass metrics::AbcSize cop
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
      create_list(:institution, 2, :in_nyc, version_id: Version.current_production.id)
      create(:institution, :in_chicago, online_only: true, version_id: Version.current_production.id)
      create(:institution, :in_new_rochelle, distance_learning: true, version_id: Version.current_production.id)
      # adding a non approved institutions row
      create(:institution, :contains_harv, approved: false, version_id: Version.current_production.id)
    end

    it 'search returns results' do
      get(:index)
      expect(JSON.parse(response.body)['data'].count).to eq(4)
      expect(response.content_type).to eq('application/json')
      expect(response).to match_response_schema('institutions')
    end

    it 'search returns results matching name' do
      get(:index, params: { name: 'chicago' })
      expect(JSON.parse(response.body)['data'].count).to eq(1)
      expect(response.content_type).to eq('application/json')
      expect(response).to match_response_schema('institutions')
    end

    it 'search returns results fuzzy-matching name' do
      create(:institution, :independent_study, version_id: Version.current_production.id)
      create(:institution, :uchicago, version_id: Version.current_production.id)
      get(:index, params: { name: 'UNIVERSITY OF NDEPENDENT STUDY', fuzzy_search: true })
      expect(JSON.parse(response.body)['data'].count).to eq(2)
      expect(response.content_type).to eq('application/json')
      expect(response).to match_response_schema('institutions')
    end

    it 'search returns results fuzzy-matching with exact match name' do
      first = create(:institution, :independent_study, version_id: Version.current_production.id)
      create(:institution, :uchicago, version_id: Version.current_production.id)
      get(:index, params: { name: 'UNIVERSITY OF INDEPENDENT STUDY', fuzzy_search: true })
      expect(JSON.parse(response.body)['data'].count).to eq(2)
      expect(JSON.parse(response.body)['data'][0]['attributes']['name']).to eq(first.institution)
      expect(response.content_type).to eq('application/json')
      expect(response).to match_response_schema('institutions')
    end

    it 'search returns results fuzzy-matching city' do
      create(:institution, :independent_study, city: 'VERY LONG CITY NAME', version_id: Version.current_production.id)
      get(:index, params: { name: 'VERY LONG CITY AME', fuzzy_search: true })
      expect(JSON.parse(response.body)['data'].count).to eq(1)
      expect(response.content_type).to eq('application/json')
      expect(response).to match_response_schema('institutions')
    end

    it 'search returns results correctly ordered results' do
      first = create(:institution, institution: 'HARVAR', gibill: 1, version_id: Version.current_production.id)
      create(:institution, institution: 'HARVARDY', gibill: 100, version_id: Version.current_production.id)
      get(:index, params: { name: 'HARVARD', fuzzy_search: true })
      expect(JSON.parse(response.body)['data'][0]['attributes']['name']).to eq(first.institution)
      expect(response.content_type).to eq('application/json')
      expect(response).to match_response_schema('institutions')
    end

    it 'search uses fuzzy_search flag' do
      create(:institution, :independent_study, version_id: Version.current_production.id)
      get(:index, params: { name: 'UNIVERSITY OF NDEPENDENT STUDY' })
      expect(JSON.parse(response.body)['data'].count).to eq(0)
      expect(response.content_type).to eq('application/json')
      expect(response).to match_response_schema('institutions')
    end

    it 'search returns results zip' do
      create(:institution, :independent_study, zip: '29461', version_id: Version.current_production.id)
      get(:index, params: { name: '29461', fuzzy_search: true })
      expect(JSON.parse(response.body)['data'].count).to eq(1)
      expect(response.content_type).to eq('application/json')
      expect(response).to match_response_schema('institutions')
    end

    it 'search returns results alias' do
      create(:institution, :independent_study, ialias: 'UIS', version_id: Version.current_production.id)
      get(:index, params: { name: 'uis', fuzzy_search: true })
      expect(JSON.parse(response.body)['data'].count).to eq(1)
      expect(response.content_type).to eq('application/json')
      expect(response).to match_response_schema('institutions')
    end

    it 'search returns case-insensitive results' do
      get(:index, params: { name: 'CHICAGO' })
      expect(JSON.parse(response.body)['data'].count).to eq(1)
      expect(response.content_type).to eq('application/json')
      expect(response).to match_response_schema('institutions')
    end

    it 'search with space returns results' do
      get(:index, params: { name: 'New Roch' })
      expect(JSON.parse(response.body)['data'].count).to eq(1)
      expect(response.content_type).to eq('application/json')
      expect(response).to match_response_schema('institutions')
    end

    it 'do not return results for extension institutions' do
      create(:institution, :contains_harv, version_id: Version.current_production.id)
      create(:institution, :contains_harv, campus_type: 'E', version_id: Version.current_production.id)
      create(:institution, :contains_harv, campus_type: 'Y', version_id: Version.current_production.id)
      get(:index, params: { name: 'harv' })
      expect(JSON.parse(response.body)['data'].count).to eq(2)
      expect(response.content_type).to eq('application/json')
      expect(response).to match_response_schema('institutions')
    end

    it 'filter by uppercase country returns results' do
      get(:index, params: { name: 'chicago', country: 'USA' })
      expect(JSON.parse(response.body)['data'].count).to eq(1)
      expect(response.content_type).to eq('application/json')
      expect(response).to match_response_schema('institutions')
    end

    it 'filter by lowercase country returns results' do
      get(:index, params: { name: 'chicago', country: 'usa' })
      expect(JSON.parse(response.body)['data'].count).to eq(1)
      expect(response.content_type).to eq('application/json')
      expect(response).to match_response_schema('institutions')
    end

    it 'filter by uppercase state returns results' do
      get(:index, params: { name: 'new', state: 'NY' })
      expect(JSON.parse(response.body)['data'].count).to eq(3)
      expect(response.content_type).to eq('application/json')
      expect(response).to match_response_schema('institutions')
    end

    it 'filters by online_only schools' do
      get(:index, params: { online_only: true })
      expect(JSON.parse(response.body)['data'].count).to eq(1)
    end

    it 'filters by distance_learning schools' do
      get(:index, params: { distance_learning: true })
      expect(JSON.parse(response.body)['data'].count).to eq(1)
    end

    it 'excludes vet_tec_provider institutions' do
      create(:institution, :vet_tec_provider, version_id: Version.current_production.id)
      create(:institution, :vet_tec_provider, vet_tec_provider: false, version_id: Version.current_production.id)
      get(:index, params: { name: 'vet tec' })
      expect(JSON.parse(response.body)['data'].map { |a| a['attributes']['vet_tec_provider'] }).to all(eq(false))
    end

    it 'filters by preferred_provider' do
      create(:institution, :in_nyc, version_id: Version.current_production.id)
      create(:institution, :preferred_provider, version_id: Version.current_production.id)
      get(:index, params: { preferred_provider: true })
      expect(JSON.parse(response.body)['data'].map { |a| a['attributes']['preferred_provider'] }).to all(eq(true))
    end

    it 'filter by lowercase state returns results' do
      get(:index, params: { name: 'new', state: 'ny' })
      expect(JSON.parse(response.body)['data'].count).to eq(3)
      expect(response.content_type).to eq('application/json')
      expect(response).to match_response_schema('institutions')
    end

    it 'has facet metadata' do
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
  end

  context 'with category and type search results' do
    before do
      create(:version, :production)
      create(:institution, :in_nyc, :production_version)
      create(:institution, :ca_employer, :production_version)
    end

    it 'filters by employer category' do
      get(:index, params: { category: 'employer' })
      expect(JSON.parse(response.body)['data'].count).to eq(1)
      expect(response.content_type).to eq('application/json')
      expect(response).to match_response_schema('institutions')
    end

    it 'filters by school category' do
      get(:index, params: { category: 'school' })
      expect(JSON.parse(response.body)['data'].count).to eq(1)
      expect(response.content_type).to eq('application/json')
      expect(response).to match_response_schema('institutions')
    end

    it 'filters by employer type' do
      get(:index, params: { type: 'ojt' })
      expect(JSON.parse(response.body)['data'].count).to eq(1)
      expect(response.content_type).to eq('application/json')
      expect(response).to match_response_schema('institutions')
    end

    it 'filters by school type' do
      get(:index, params: { type: 'private' })
      expect(JSON.parse(response.body)['data'].count).to eq(1)
      expect(response.content_type).to eq('application/json')
      expect(response).to match_response_schema('institutions')
    end
  end

  context 'with institution profile' do
    before do
      create(:version, :production)
    end

    it 'returns profile details' do
      school = create(:institution, :in_chicago, :production_version)
      get(:show, params: { id: school.facility_code })
      expect(response.content_type).to eq('application/json')
      expect(response).to match_response_schema('institution_profile')
    end

    it 'returns profile details for VET TEC institution' do
      school = create(:institution, :vet_tec_provider, :production_version)
      get(:show, params: { id: school.facility_code })
      expect(response.content_type).to eq('application/json')
      expect(response).to match_response_schema('institution_profile')
    end

    it 'returns common exception response if school not found' do
      get(:show, params: { id: '10000' })
      assert_response :missing
      expect(response.content_type).to eq('application/json')
      expect(response).to match_response_schema('errors')
    end
  end

  context 'with institution children' do
    before do
      create(:version, :production)
    end

    it 'returns institution children' do
      school = create(:institution, :in_chicago, :production_version)

      child_school = create(:institution, :in_chicago, parent_facility_code_id: school.facility_code, version_id: school.version_id)
      get(:children, params: { id: school.facility_code })
      expect(response.content_type).to eq('application/json')

      expect(JSON.parse(response.body)['data'].count).to eq(1)
      expect(JSON.parse(response.body)['data'][0]['attributes']['facility_code']).to eq(child_school.facility_code)
      expect(JSON.parse(response.body)['data'][0]['attributes']['parent_facility_code_id']).to eq(school.facility_code)
      expect(response).to match_response_schema('institutions')
    end

    it 'returns empty record set' do
      get(:children, params: { id: '10000' })
      expect(response.content_type).to eq('application/json')
      expect(JSON.parse(response.body)['data'].count).to eq(0)
    end
  end
end
