# frozen_string_literal: true

require 'rails_helper'
require 'models/shared_examples/shared_examples_for_exportable_by_version'

RSpec.describe Institution, type: :model do
  it_behaves_like 'an exportable model by version'

  describe 'when validating' do
    it 'has a valid factory' do
      version = create(:version, :preview)
      institution = build :institution, version: version, version_id: version.id
      expect(institution).to be_valid
    end
  end

  describe 'scorecard_link' do
    let(:url) { 'https://collegescorecard.ed.gov/school/?1234567-myschool' }

    it 'returns a url' do
      expect(build(:institution, cross: '1234567', institution: 'myschool').scorecard_link).to eq(url)
    end

    it 'returns nil if the institution is not a school' do
      expect(build(:institution, institution_type_name: 'OJT')).not_to be_nil
    end
  end

  describe 'website_link' do
    let(:url) { 'http://myschool.com' }
    let(:https_url) { 'https://myschool.com' }

    it 'returns a url' do
      expect(build(:institution, insturl: 'myschool.com').website_link).to eq(url)
    end

    it 'returns a well-formed http url' do
      expect(build(:institution, insturl: 'http://myschool.com').website_link).to eq(url)
    end

    it 'returns a well-formed https url' do
      expect(build(:institution, insturl: 'https://myschool.com').website_link).to eq(https_url)
    end

    it 'returns nil if insturl is blank' do
      expect(build(:institution, insturl: '').website_link).to be_nil
    end
  end

  describe 'vet_website_link' do
    let(:url) { 'http://myschool.com' }
    let(:https_url) { 'https://myschool.com' }

    it 'returns a url' do
      expect(build(:institution, vet_tuition_policy_url: 'myschool.com').vet_website_link).to eq(url)
    end

    it 'returns a well-formed http url' do
      expect(build(:institution, vet_tuition_policy_url: 'http://myschool.com').vet_website_link).to eq(url)
    end

    it 'returns a well-formed https url' do
      expect(build(:institution, vet_tuition_policy_url: 'https://myschool.com').vet_website_link).to eq(https_url)
    end

    it 'returns nil if vet_tuition_policy_url is blank' do
      expect(build(:institution, vet_tuition_policy_url: '').vet_website_link).to be_nil
    end
  end

  describe 'complaints' do
    let(:complaint_fac_code) { build :institution, complaints_facility_code: 1 }

    it 'returns a hash of complaint counts' do
      complaints = complaint_fac_code.complaints

      expect(complaints['facility_code']).to eq(1)
    end
  end

  describe 'locale_type' do
    it 'maps locale numbers to descriptions' do
      {
        'city' => [11, 12, 13], 'suburban' => [21, 22, 23], 'town' => [31, 32, 33], 'rural' => [41, 42, 43]
      }.each_pair do |description, locales|
        locales.each do |locale|
          expect(build(:institution, locale: locale).locale_type).to eq(description)
        end
      end
    end

    it 'is nil for non-mapped values' do
      expect(build(:institution, locale: 1).locale_type).to be_nil
    end
  end

  describe 'highest_degree' do
    it 'maps pred_degree_awarded to a common value' do
      expect(build(:institution, pred_degree_awarded: 0).highest_degree).to be_nil
      expect(build(:institution, pred_degree_awarded: 1).highest_degree).to eq('Certificate')
      expect(build(:institution, pred_degree_awarded: 2).highest_degree).to eq(2)
      expect(build(:institution, pred_degree_awarded: 3).highest_degree).to eq(4)
      expect(build(:institution, pred_degree_awarded: 4).highest_degree).to eq(4)
    end

    it 'maps va_highest_degree_offered to a common value' do
      expect(build(:institution, va_highest_degree_offered: 0).highest_degree).to be_nil
      expect(build(:institution, va_highest_degree_offered: 'ncd').highest_degree).to eq('Certificate')
      expect(build(:institution, va_highest_degree_offered: '2-year').highest_degree).to eq(2)
      expect(build(:institution, va_highest_degree_offered: '4-year').highest_degree).to eq(4)
    end

    it 'prefers pred_degree_awarded over va_highest_degree_offered' do
      expect(build(:institution, pred_degree_awarded: 2, va_highest_degree_offered: '4-year').highest_degree).to eq(2)
    end
  end

  describe 'school?' do
    it 'returns true if an institution is not ojt' do
      expect(build(:institution, institution_type_name: 'OJT')).not_to be_school
      expect(build(:institution, institution_type_name: 'PRIVATE')).to be_school
    end
  end

  describe 'closure109' do
    it 'returns true if an institution has a school closure' do
      expect(build(:institution, closure109: false).closure109).to eq(false)
      expect(build(:institution, closure109: true).closure109).to eq(true)
    end
  end

  describe 'institution_programs' do
    before do
      create(:version, :preview)
    end

    let(:institution) { build :institution, version: Version.last, version_id: Version.last.id }

    def create_institution(institution, description)
      InstitutionProgram.create(institution: institution, description: description,
                                version: institution.version, facility_code: institution.facility_code)
    end

    it 'returns versioned institution programs' do
      create_institution(institution, 'BBB')
      expect(institution.institution_programs.count).to eq(1)
    end

    it 'returns institution programs ordered by description' do
      create_institution(institution, 'BBB')
      create_institution(institution, 'AAA')
      expect(institution.institution_programs.count).to eq(2)
      expect(institution.institution_programs.first.description).to eq('AAA')
    end
  end

  describe 'class methods and scopes' do
    context 'with filter scope' do
      it 'raises an error if no arguments are provided' do
        expect { described_class.filter_result }.to raise_error(ArgumentError)
      end

      it 'filters on field existing' do
        expect(described_class.filter_result('institution', 'true').to_sql)
          .to include("WHERE \"institutions\".\"institution\" = 't'")
      end

      it 'filters on field not existing' do
        expect(described_class.filter_result('institution', 'false').to_sql)
          .to include("WHERE \"institutions\".\"institution\" != 't'")
      end
    end

    context 'with filter v1 scope' do
      it 'filters on state only if only a state is provided in the name' do
        create(:version, :production)
        create(:institution, :in_nyc_state_country, version_id: Version.current_production.id)
        create(:institution, :in_nyc_state_only, version_id: Version.current_production.id)
        query = { 'name' => 'Hampton', 'state' => 'NY' }
        expect(described_class.search_v1(query).filter_result_v1(query).count).to eq(2)
        expect(described_class.search_v1(query).filter_result_v1(query).to_sql).to include('physical_state')
        expect(described_class.search_v1(query).filter_result_v1(query).to_sql).not_to include('physical_country')
      end
    end

    context 'with filter v1 scope without country' do
      it 'filters on state only if only a state is provided in the name' do
        create(:version, :production)
        create(:institution, :in_nyc_state_country, version_id: Version.current_production.id)
        create(:institution, :in_nyc_state_only, version_id: Version.current_production.id)
        query = { 'name' => 'Hampton', 'state' => 'NY', 'country' => 'USA' }
        expect(described_class.search_v1(query).filter_result_v1(query).count).to eq(1)
        expect(described_class.search_v1(query).filter_result_v1(query).to_sql).to include('physical_country')
      end
    end

    context 'with special mission filters' do
      it 'applies special mission filters except relaffil if applicable' do
        query = { 'special_mission_hbcu' => 'true' }
        expect(described_class.set_special_mission_filters(query))
          .to include('hbcu = 1')
      end

      it 'applies relaffil special mission filter if applicable' do
        query = { 'special_mission_relaffil' => 'true' }
        expect(described_class.set_special_mission_filters(query))
          .to include('relaffil is not null')
      end
    end

    context 'with search scope' do
      it 'returns nil if no search term is provided' do
        expect(described_class.search(nil)).to be_empty
      end

      it 'includes the address fields if include_address is set' do
        version = create(:version, :production)
        institution = create(:institution, physical_address_1: 'address_1', version_id: version.id, version: version)
        expect(described_class.search({ name: 'address_1', include_address: true }).take).to eq(institution)
        expect(described_class.search({ name: 'address_1' }).count).to eq(0)
      end
    end

    context 'with search order sorts ' do
      before do
        create(:version, :production)
        create_list(:institution, 2, :in_nyc, version_id: Version.current_production.id)
        create(:institution, :in_chicago, online_only: true, version_id: Version.current_production.id)
        create(:institution, :in_new_rochelle, distance_learning: true, version_id: Version.current_production.id)
        # adding a non approved institutions row
        create(:institution, :contains_harv, approved: false, version_id: Version.current_production.id)
      end

      it 'ialias exact match' do
        institution = create(:institution, :mit)
        search_term = institution.ialias
        query = { name: search_term }
        results = described_class.search(query).search_order(query)
        expect(results[0].ialias).to eq(search_term)
      end

      it 'ialias contains the search term as a word' do
        create(:institution, ialias: 'KU | KANSAS UNIVERSITY', institution: 'KANSAS UNIVERSITY NORTH')
        search_term = 'KU'
        query = { name: search_term }
        results = described_class.search(query).search_order(query)
        expect(results[0].ialias).to include(search_term)
      end

      ['!', '$', '(', ')', '*', '+', '.', ':', '<', '=', '>', '?', '[', ']', '^', '{', '|', '}', '-', "'"].each do |postgresql_regex_char|
        it "institution matches with postgresql regex special character \"#{postgresql_regex_char}\" in search term" do
          create(:institution, ialias: 'KU | KANSAS UNIVERSITY', institution: "KANSAS#{postgresql_regex_char} UNIVERSITY NORTH")
          search_term = "KANSAS#{postgresql_regex_char}"
          query = { name: search_term }
          results = described_class.search(query).search_order(query)
          expect(results[0].institution).to include(search_term)
        end
      end

      it 'institution exact match' do
        institution = create(:institution, :mit)
        search_term = institution.institution
        query = { name: search_term }
        results = described_class.search(query).search_order(query)
        expect(results[0].institution).to eq(search_term)
      end

      it 'city exact match' do
        institution = create(:institution, :mit)
        search_term = institution.physical_city
        query = { name: search_term }
        results = described_class.search(query).search_order(query)
        expect(results[0].physical_city).to eq(search_term)
      end

      it 'gibill value' do
        create(:institution, :mit, gibill: 1)
        institution = create(:institution, :mit)
        max_gibill = described_class.maximum(:gibill)
        query = { name: institution.institution }
        results = described_class.search(query).search_order(query, max_gibill)
        expect(results[0].gibill).to eq(max_gibill)
      end
    end

    it 'approved institutions' do
      create(:version, :production)
      create(:institution, version_id: Version.current_production.id)
      create(:institution, approved: false, version_id: Version.current_production.id)
      results = described_class.approved_institutions(Version.current_production)
      expect(results.count).to eq(1)
    end

    it 'non vet tec institutions' do
      create(:version, :production)
      create(:institution, version_id: Version.current_production.id)
      create(:institution, approved: false, version_id: Version.current_production.id)
      create(:institution, :vet_tec_provider, version_id: Version.current_production.id)

      results = described_class.non_vet_tec_institutions(Version.current_production)
      expect(results.count).to eq(1)
    end

    it 'excludes high schools when filtering them out' do
      create(:version, :production)
      create(:institution, version_id: Version.current_production.id)
      create(:institution, :high_school_institution, version_id: Version.current_production.id)
      results = described_class.filter_high_school
      expect(results.count).to eq(0)
    end

    describe '#institution_search_term' do
      it 'removes common words and characters' do
        common_words_characters = (Settings.search.common_word_list + Settings.search.common_character_list).join(' ')
        search_term = "search term #{common_words_characters}"
        processed = described_class.institution_search_term(search_term)
        processed_search_term = processed[:search_term]
        excluded_only = processed[:excluded_only]
        expect(processed_search_term).to eq('search term')
        expect(processed_search_term).not_to include(common_words_characters)
        expect(excluded_only).to be_falsey
      end

      it 'returns string if only contains common words' do
        search_term = (Settings.search.common_word_list + Settings.search.common_character_list).join(' ')
        processed = described_class.institution_search_term(search_term)
        processed_search_term = processed[:search_term]
        excluded_only = processed[:excluded_only]
        expect(processed_search_term).to eq(search_term)
        expect(processed_search_term).to be_present
        expect(excluded_only).to be_truthy
      end

      it 'does not remove common words within words' do
        common_words_characters = (Settings.search.common_word_list + Settings.search.common_character_list).join(' ')
        search_term = 'university of maryland & and land'
        processed = described_class.institution_search_term(search_term)
        processed_search_term = processed[:search_term]
        excluded_only = processed[:excluded_only]
        expect(processed_search_term).not_to include(common_words_characters)
        expect(processed_search_term).to eq('maryland   land')
        expect(excluded_only).to be_falsey
      end
    end
  end

  describe 'physical_address' do
    let(:institution) { build :institution }

    it 'returns physical_address' do
      expect(institution.physical_address).to eq(nil)
    end
  end

  context 'when reporting on ungeocodables' do
    before do
      create(:version, :production)
      create(:institution, :location, :lat_long)
      create(:institution, :foreign_bad_address, :ungeocodable)

      # rubocop:disable Rails/SkipsModelValidations
      described_class.update_all version_id: Version.first.id
      # rubocop:enable Rails/SkipsModelValidations
    end

    it 'returns ungeocodable institutions for #ungeocodables' do
      expect(described_class.ungeocodables.size).to eq(1)
    end

    it 'returns a count of ungeocodable institutions for #ungeocodable_count' do
      expect(described_class.ungeocodable_count).to eq(1)
    end
  end
end
