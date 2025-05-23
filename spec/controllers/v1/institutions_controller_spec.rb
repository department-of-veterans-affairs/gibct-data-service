# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V1::InstitutionsController, type: :controller do
  def expect_response_match_schema(schema)
    expect(response.media_type).to eq('application/json')
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
      create(:version, :production, :with_institution_that_contains_harv)
      get(:index)
      expect_response_match_schema('institution_search_results')
    end

    def preview_body(body)
      JSON.parse(body)
    end

    it 'accepts invalid version parameter and returns production data' do
      create(:version, :production, :with_institution_that_contains_harv)
      get(:index, params: { version: 'invalid_data' })
      expect(response.media_type).to eq('application/json')
      expect(response).to match_response_schema('institution_search_results')
      body = JSON.parse response.body
      expect(body['meta']['version']['number'].to_i).to eq(Version.current_production.number)
    end

    it 'accepts version number as a version parameter and returns preview data' do
      create(:version, :production, :with_institution_that_contains_harv)
      v = create(:version, :preview)
      get(:index, params: { version: v.uuid })
      expect(response.media_type).to eq('application/json')
      expect(response).to match_response_schema('institution_search_results')
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
      expect(response.media_type).to eq('application/json')
      expect(response).to match_response_schema('autocomplete')
    end

    it 'limits results to 6' do
      create_list(:institution, 7, :start_like_harv, :production_version, approved: true)
      get(:autocomplete, params: { term: 'harv' })
      expect(JSON.parse(response.body)['data'].count).to eq(6)
      expect(response.media_type).to eq('application/json')
      expect(response).to match_response_schema('autocomplete')
    end

    it 'returns empty collection on missing term parameter' do
      create(:version, :production, :with_institution_that_starts_like_harv)
      get(:autocomplete)
      expect(JSON.parse(response.body)['data'].count).to eq(0)
      expect(response.media_type).to eq('application/json')
      expect(response).to match_response_schema('autocomplete')
    end

    it 'does not return results for non-approved institutions' do
      create(:institution, :production_version, :start_like_harv, approved: false)
      get(:autocomplete, params: { term: 'harv' })
      expect(JSON.parse(response.body)['data'].count).to eq(0)
      expect(response.media_type).to eq('application/json')
      expect(response).to match_response_schema('autocomplete')
    end

    it 'does not return results for extension institutions' do
      create(:institution, :start_like_harv, :production_version, campus_type: 'E')
      create(:institution, :start_like_harv, :production_version, campus_type: 'Y')
      create(:institution, :start_like_harv, :production_version)
      get(:autocomplete, params: { term: 'harv' })
      expect(JSON.parse(response.body)['data'].count).to eq(2)
      expect(response.media_type).to eq('application/json')
      expect(response).to match_response_schema('autocomplete')
    end

    it 'includes vet_tec_provider institutions' do
      create(:institution, :production_version, :vet_tec_provider, :start_like_harv)
      get(:autocomplete, params: { term: 'harv' })
      expect(JSON.parse(response.body)['data'].count).to eq(1)
      expect(response.media_type).to eq('application/json')
      expect(response).to match_response_schema('autocomplete')
    end

    it 'excludes institutions with caution flags' do
      institution = create(:institution, :start_like_harv, :production_version)
      create(:institution, :exclude_caution_flags, :start_like_harv, :production_version)
      get(:autocomplete, params: { term: 'harv', exclude_caution_flags: true })
      expect(JSON.parse(response.body)['data'].count).to eq(1)
      expect(JSON.parse(response.body)['data'][0]['id']).to eq(institution.id)
      expect(response.media_type).to eq('application/json')
      expect(response).to match_response_schema('autocomplete')
    end

    it 'excludes institutions with school closing flag' do
      institution = create(:institution, :start_like_harv, :production_version)
      create(:institution, :exclude_school_closing, :start_like_harv, :production_version)
      get(:autocomplete, params: { term: 'harv', exclude_caution_flags: true })
      expect(JSON.parse(response.body)['data'].count).to eq(1)
      expect(JSON.parse(response.body)['data'][0]['id']).to eq(institution.id)
      expect(response.media_type).to eq('application/json')
      expect(response).to match_response_schema('autocomplete')
    end

    it 'filters by excluding type' do
      institution = create(:institution, :start_like_harv, :production_version)
      create(:institution, :start_like_harv, :production_version, institution_type_name: Weam::PUBLIC)
      get(:autocomplete, params: { term: 'harv', excluded_school_types: [Weam::PUBLIC] })
      expect(JSON.parse(response.body)['data'].count).to eq(1)
      expect(JSON.parse(response.body)['data'][0]['id']).to eq(institution.id)
      expect(response.media_type).to eq('application/json')
      expect(response).to match_response_schema('autocomplete')
    end

    it 'filters by exclude schools' do
      institution = create(:institution, :start_like_harv, :production_version)
      create(:institution, :start_like_harv, :production_version, :employer)
      get(:autocomplete, params: { term: 'harv', exclude_schools: true })
      expect(JSON.parse(response.body)['data'].count).to eq(1)
      expect(JSON.parse(response.body)['data'][0]['id']).not_to eq(institution.id)
      expect(response.media_type).to eq('application/json')
      expect(response).to match_response_schema('autocomplete')
    end

    it 'filters by country' do
      institution = create(:institution, :start_like_harv, :production_version)
      create(:institution, :start_like_harv, :production_version, country: 'CAN', physical_country: 'CAN')
      get(:autocomplete, params: { term: 'harv', country: 'usa' })
      expect(JSON.parse(response.body)['data'].count).to eq(1)
      expect(JSON.parse(response.body)['data'][0]['id']).to eq(institution.id)
      expect(response.media_type).to eq('application/json')
      expect(response).to match_response_schema('autocomplete')
    end

    it 'filters by state' do
      institution = create(:institution, :start_like_harv, :production_version)
      create(:institution, :start_like_harv, :production_version, state: 'MD', physical_state: 'MD')
      get(:autocomplete, params: { term: 'harv', state: 'ma' })
      expect(JSON.parse(response.body)['data'].count).to eq(1)
      expect(JSON.parse(response.body)['data'][0]['id']).to eq(institution.id)
      expect(response.media_type).to eq('application/json')
      expect(response).to match_response_schema('autocomplete')
    end

    it 'filters by student_veteran' do
      institution = create(:institution, :start_like_harv, :production_version, student_veteran: 'true')
      create(:institution, :start_like_harv, :production_version)
      get(:autocomplete, params: { term: 'harv', student_veteran: true })
      expect(JSON.parse(response.body)['data'].count).to eq(1)
      expect(JSON.parse(response.body)['data'][0]['id']).to eq(institution.id)
      expect(response.media_type).to eq('application/json')
      expect(response).to match_response_schema('autocomplete')
    end

    it 'filters by yellow_ribbon_scholarship' do
      institution = create(:institution, :start_like_harv, :production_version, yr: 'true')
      create(:institution, :start_like_harv, :production_version)
      get(:autocomplete, params: { term: 'harv', yellow_ribbon_scholarship: true })
      expect(JSON.parse(response.body)['data'].count).to eq(1)
      expect(JSON.parse(response.body)['data'][0]['id']).to eq(institution.id)
      expect(response.media_type).to eq('application/json')
      expect(response).to match_response_schema('autocomplete')
    end

    it 'filters by preferred_provider' do
      institution = create(:institution, :start_like_harv, :production_version, vet_tec_provider: true, preferred_provider: true)
      create(:institution, :start_like_harv, :production_version)
      get(:autocomplete, params: { term: 'harv', preferred_provider: true })
      expect(JSON.parse(response.body)['data'].count).to eq(2)
      vet_tec_providers_id = JSON.parse(response.body)['data'].map { |r| r['id'] }
      expect(vet_tec_providers_id).to include(institution.id)
      expect(response.media_type).to eq('application/json')
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
      create_list(:institution, 2, :in_nyc, :production_version)
      create(:institution, :production_version, :in_chicago, online_only: true)
      create(:institution, :production_version, :in_new_rochelle, distance_learning: true)
      # adding a non approved institutions row
      create(:institution, :production_version, :contains_harv, approved: false)
    end

    it 'search returns results' do
      get(:index)
      expect(JSON.parse(response.body)['data'].count).to eq(4)
      expect(response.media_type).to eq('application/json')
      expect(response).to match_response_schema('institution_search_results')
    end

    it 'search returns results matching name' do
      create(:institution, :uchicago, :production_version)
      get(:index, params: { name: 'UNIVERSITY OF CHICAGO - NOT IN CHICAGO' })
      expect(JSON.parse(response.body)['data'].count).to eq(1)
      expect(response.media_type).to eq('application/json')
      expect(response).to match_response_schema('institution_search_results')
    end

    it 'search returns results fuzzy-matching name' do
      create(:institution, :independent_study, :production_version)
      create(:institution, :uchicago, :production_version)
      get(:index, params: { name: 'UNIVERSITY OF NDEPENDENT STUDY' })
      expect(JSON.parse(response.body)['data'].count).to eq(1)
      expect(response.media_type).to eq('application/json')
      expect(response).to match_response_schema('institution_search_results')
    end

    it 'search returns results fuzzy-matching with exact match name' do
      first = create(:institution, :independent_study, :production_version)
      create(:institution, :uchicago, :production_version)
      get(:index, params: { name: 'UNIVERSITY OF INDEPENDENT STUDY' })
      expect(JSON.parse(response.body)['data'].count).to eq(1)
      expect(JSON.parse(response.body)['data'][0]['attributes']['name']).to eq(first.institution)
      expect(response.media_type).to eq('application/json')
      expect(response).to match_response_schema('institution_search_results')
    end

    it 'search returns results correctly ordered results' do
      create(:institution, :production_version, institution: 'HARVAR', institution_search: 'HARVAR', gibill: 1)
      first = create(:institution, :production_version,
                     institution: 'HARVARDY', institution_search: 'HARVARDY', gibill: 100)
      get(:index, params: { name: 'HARVARD' })
      expect(JSON.parse(response.body)['data'][0]['attributes']['name']).to eq(first.institution)
      expect(response.media_type).to eq('application/json')
      expect(response).to match_response_schema('institution_search_results')
    end

    it 'search returns results alias' do
      create(:institution, :production_version, :independent_study, ialias: 'UIS')
      get(:index, params: { name: 'uis' })
      expect(JSON.parse(response.body)['data'].count).to eq(1)
      expect(response.media_type).to eq('application/json')
      expect(response).to match_response_schema('institution_search_results')
    end

    it 'search returns case-insensitive results' do
      get(:index, params: { name: 'InsTiTUTIon' })
      expect(JSON.parse(response.body)['data'].count).to eq(4)
      expect(response.media_type).to eq('application/json')
      expect(response).to match_response_schema('institution_search_results')
    end

    it 'search with space returns results' do
      create(:institution, :production_version, institution_search: 'with space')
      get(:index, params: { name: 'with space' })
      expect(JSON.parse(response.body)['data'].count).to eq(1)
      expect(response.media_type).to eq('application/json')
      expect(response).to match_response_schema('institution_search_results')
    end

    it 'do not return results for extension institutions' do
      create(:institution, :production_version, :ca_employer)
      create(:institution, :production_version, :ca_employer, campus_type: 'E')
      create(:institution, :production_version, :ca_employer, campus_type: 'Y')
      get(:index, params: { name: 'acme' })

      expect(JSON.parse(response.body)['data'].count).to eq(2)
      expect(response.media_type).to eq('application/json')
      expect(response).to match_response_schema('institution_search_results')
    end

    it 'filter by uppercase country returns results' do
      get(:index, params: { name: 'institution', country: 'USA' })
      expect(JSON.parse(response.body)['data'].count).to eq(3)
      expect(response.media_type).to eq('application/json')
      expect(response).to match_response_schema('institution_search_results')
    end

    it 'filter by lowercase country returns results' do
      get(:index, params: { name: 'institution', country: 'usa' })
      expect(JSON.parse(response.body)['data'].count).to eq(3)
      expect(response.media_type).to eq('application/json')
      expect(response).to match_response_schema('institution_search_results')
    end

    it 'filter by uppercase state returns results' do
      get(:index, params: { state: 'NY' })
      expect(JSON.parse(response.body)['data'].count).to eq(3)
      expect(response.media_type).to eq('application/json')
      expect(response).to match_response_schema('institution_search_results')
    end

    it 'includes vet_tec_provider institutions' do
      vet_tec = create(:institution, :production_version, :vet_tec_provider)
      get(:index, params: { name: 'vet tec' })
      expect(JSON.parse(response.body)['data'][0]['attributes']['facility_code']).to eq(vet_tec.facility_code)
    end

    it 'excludes vet_tec_provider institutions' do
      create(:institution, :production_version, :vet_tec_provider)
      get(:index, params: { name: 'vet tec', exclude_vettec: true })
      expect(JSON.parse(response.body)['data'].count).to eq(0)
    end

    it 'filters by preferred_provider' do
      create(:institution, :production_version, :in_nyc)
      create(:institution, :production_version, :preferred_provider)
      get(:index, params: { exclude_schools: true, exclude_employers: true, preferred_provider: true })
      expect(JSON.parse(response.body)['data'].map { |a| a['attributes']['preferred_provider'] }).to all(eq(true))
    end

    it 'filter by lowercase state returns results' do
      get(:index, params: { state: 'ny' })
      expect(JSON.parse(response.body)['data'].count).to eq(3)
      expect(response.media_type).to eq('application/json')
      expect(response).to match_response_schema('institution_search_results')
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

  context 'with location results' do
    before do
      create(:version, :production)
    end

    it 'search returns location results' do
      create(:institution, :production_version, :location)
      get(:location, params: { latitude: '32.7876', longitude: '-79.9403', distance: '50', tab: 'location' })
      expect(JSON.parse(response.body)['data'].count).to eq(1)
      expect(response.media_type).to eq('application/json')
      expect(response).to match_response_schema('institution_search_results')
    end

    # tests for coordinate-based name+location search
    it 'returns filtered results when searching by both name and coordinates' do
      create(:institution, :production_version, :location, institution: 'HARVARD UNIVERSITY')
      create(:institution, :production_version, :location, institution: 'BOSTON UNIVERSITY')

      get(:location, params: {
            latitude: '32.7876',
            longitude: '-79.9403',
            distance: '50',
            name: 'harvard'
          })

      results = JSON.parse(response.body)['data']
      expect(results.count).to eq(1)
      expect(results[0]['attributes']['name']).to eq('HARVARD UNIVERSITY')
      expect(response).to match_response_schema('institution_search_results')
    end

    it 'returns no results when name does not match within location radius' do
      create(:institution, :production_version, :location, institution: 'HARVARD UNIVERSITY')

      get(:location, params: {
            latitude: '32.7876',
            longitude: '-79.9403',
            distance: '50',
            name: 'stanford'
          })

      expect(JSON.parse(response.body)['data'].count).to eq(0)
      expect(response).to match_response_schema('institution_search_results')
    end

    it 'maintains accurate count in meta for coordinate and name search' do
      create_list(:institution, 3, :production_version, :location)
      create(:institution, :production_version, :location, institution: 'HARVARD UNIVERSITY')

      get(:location, params: {
            latitude: '32.7876',
            longitude: '-79.9403',
            distance: '50',
            name: 'harvard'
          })

      body = JSON.parse(response.body)
      expect(body['data'].count).to eq(1)
      expect(body['meta']['count']).to eq(1)
      expect(response).to match_response_schema('institution_search_results')
    end
  end

  context 'with compare results' do
    before do
      create(:version, :production)
    end

    it 'search returns compare results' do
      i1 = create(:institution, :production_version)
      i2 = create(:institution, :production_version)
      i3 = create(:institution, :production_version)
      get(:facility_codes, params: { facility_codes: [i1.facility_code, i2.facility_code, i3.facility_code] })
      expect(JSON.parse(response.body)['data'].count).to eq(3)
      expect(response.media_type).to eq('application/json')
      expect(response).to match_response_schema('institution_compare_results')
    end
  end

  context 'with category and type search results' do
    before do
      create(:version, :production)
      create(:institution, :in_nyc, :production_version)
      create(:institution, :ca_employer, :production_version)
    end

    it 'filters by employer category' do
      get(:index, params: { category: 'employer', name: 'acme' })
      expect(JSON.parse(response.body)['data'].count).to eq(1)
      expect(response.media_type).to eq('application/json')
      expect(response).to match_response_schema('institution_search_results')
    end

    it 'filters by school category' do
      get(:index, params: { category: 'school', name: 'institution' })
      expect(JSON.parse(response.body)['data'].count).to eq(1)
      expect(response.media_type).to eq('application/json')
      expect(response).to match_response_schema('institution_search_results')
    end

    it 'filters by employer type' do
      get(:index, params: { type: Weam::OJT, name: 'acme' })
      expect(JSON.parse(response.body)['data'].count).to eq(1)
      expect(response.media_type).to eq('application/json')
      expect(response).to match_response_schema('institution_search_results')
    end

    it 'filters by school type' do
      get(:index, params: { type: Weam::PRIVATE, name: 'institution' })
      expect(JSON.parse(response.body)['data'].count).to eq(1)
      expect(response.media_type).to eq('application/json')
      expect(response).to match_response_schema('institution_search_results')
    end
  end

  context 'with institution profile' do
    before { create(:version, :production) }

    it 'returns profile details' do
      school = create(:institution, :in_chicago, :production_version)
      get(:show, params: { id: school.facility_code })
      expect(response.media_type).to eq('application/json')
      expect(response).to match_response_schema('institution_profile')
    end

    it 'returns profile details for VET TEC institution' do
      school = create(:institution, :vet_tec_provider, :production_version)
      get(:show, params: { id: school.facility_code })
      expect(response.media_type).to eq('application/json')
      expect(response).to match_response_schema('institution_profile')
    end

    it 'returns common exception response if school not found' do
      get(:show, params: { id: '10000' })
      assert_response :missing
      expect(response.media_type).to eq('application/json')
      expect(response).to match_response_schema('errors')
    end

    # rubocop:disable RSpec/LetSetup
    context 'with versioned complaints present' do
      let(:other_version) { create :version }
      let!(:school) { create :institution, ope: '00279100', ope6: '02791', version_id: Version.current_production.id }
      let!(:versioned_complaints) do
        [
          create(:versioned_complaint, version_id: Version.current_production.id, facility_code: school.facility_code, ope6: school.ope6, status: 'closed'), # match by facility_code and ope6
          create(:versioned_complaint, version_id: Version.current_production.id, facility_code: '99999999', ope6: school.ope6, status: 'closed'), # match by ope6
          create(:versioned_complaint, version_id: Version.current_production.id, facility_code: '99999999', ope6: school.ope6, status: 'closed'), # match by ope6
          create(:versioned_complaint, version_id: Version.current_production.id, facility_code: school.facility_code, ope6: school.ope6, status: 'active'), # wrong status
          create(:versioned_complaint, version_id: other_version.id, facility_code: school.facility_code, ope6: school.ope6, status: 'closed') # wrong version
        ]
      end

      it 'returns only those complaints associated with the given institution' do
        get(:show, params: { id: school.facility_code })
        data = JSON.parse(response.body)['data']
        expect(data['attributes']['all_facility_code_complaints'].size).to eq(1)
        expect(data['attributes']['all_ope6_complaints'].size).to eq(3)
      end
    end
    # rubocop:enable RSpec/LetSetup
  end

  context 'with institution children' do
    before { create(:version, :production) }

    it 'returns institution children' do
      school = create(:institution, :in_chicago, :production_version)

      child_school = create(:institution, :in_chicago, parent_facility_code_id: school.facility_code, version_id: school.version_id)
      get(:children, params: { id: school.facility_code })
      expect(response.media_type).to eq('application/json')

      expect(JSON.parse(response.body)['data'].count).to eq(1)
      expect(JSON.parse(response.body)['data'][0]['attributes']['facility_code']).to eq(child_school.facility_code)
      expect(JSON.parse(response.body)['data'][0]['attributes']['parent_facility_code_id']).to eq(school.facility_code)
      expect(response).to match_response_schema('institutions')
    end

    it 'returns empty record set' do
      get(:children, params: { id: '10000' })
      expect(response.media_type).to eq('application/json')
      expect(JSON.parse(response.body)['data'].count).to eq(0)
    end
  end

  context 'with program search results' do
    before do
      create(:version, :production)
      create(:institution, :production_version, latitude: 30.1659, longitude: -93.2146) # Example institution
      create(:institution_program, institution: Institution.last, description: 'Software Engineering') # Program associated with the institution
    end

    it 'search returns results matching program description and location' do
      get(:program, params: { description: 'Software Engineering', latitude: 30.1659, longitude: -93.2146 })
      expect(JSON.parse(response.body)['data'].count).to eq(1) # Expecting one result
      expect(response.media_type).to eq('application/json')
      expect(response).to match_response_schema('institution_search_results')
    end

    it 'returns no results for non-matching program description' do
      get(:program, params: { description: 'Non-existing Program', latitude: 30.1659, longitude: -93.2146 })
      expect(JSON.parse(response.body)['data'].count).to eq(0) # Expecting no results
      expect(response.media_type).to eq('application/json')
      expect(response).to match_response_schema('institution_search_results')
    end

    it 'returns no results for non-matching location' do
      get(:program, params: { description: 'Software Engineering', latitude: 0.0, longitude: 0.0 })
      expect(JSON.parse(response.body)['data'].count).to eq(0) # Expecting no results
      expect(response.media_type).to eq('application/json')
      expect(response).to match_response_schema('institution_search_results')
    end
  end
end
