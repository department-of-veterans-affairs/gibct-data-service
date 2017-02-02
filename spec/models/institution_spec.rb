# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Institution, type: :model do
  describe 'class methods and scopes' do
    context 'filter scope' do
      it 'should raise an error if no arguments are provided' do
        expect { described_class.filter }.to raise_error(ArgumentError)
      end

      it 'should filter on field existing' do
        expect(described_class.filter('institution', 'true').to_sql)
          .to include("WHERE \"institutions\".\"institution\" = 't'")
      end

      it 'should filter on field not existing' do
        expect(described_class.filter('institution', 'false').to_sql)
          .to include("WHERE (\"institutions\".\"institution\" != 't')")
      end
    end

    context 'search scope' do
      it 'should return nil if no search term is provided' do
        expect(described_class.search(name: nil)).to be_empty
      end

      it 'should search when attribute is provided' do
        expect(described_class.search(name: 'chicago').to_sql)
          .to include("WHERE (lower(facility_code) = ('---\n- :name\n- chicago\n') OR lower(institution) LIKE ('%{:name=>\"chicago\"}%') OR lower(city) LIKE ('%{:name=>\"chicago\"}%'))")
      end
    end
  end

  describe 'instance methods' do
    context 'vets_website_link' do
      it 'is nil when tuition policy url is blank' do
        expect(build(:institution, vet_tuition_policy_url: '').vet_website_link)
          .to be_nil
      end

      it 'matches tuition policy' do
        expect(build(:institution, vet_tuition_policy_url: 'test.gov').vet_website_link)
          .to eq('http://test.gov')
      end
    end
  end

  describe 'when validating' do
    subject { create :institution }

    it 'has a valid factory' do
      expect(subject).to be_valid
    end

    it 'requires uniqueness of facility_code' do
      duplicate_facility = subject.dup
      expect(duplicate_facility).not_to be_valid
      expect(duplicate_facility.errors.messages)
        .to eq(facility_code: ["has already been taken"])
    end

    it 'requires institution_type_name to be in valid TYPES' do
      expect(build :institution, institution_type_name: 'invalid_name').not_to be_valid
    end

    it 'requires institution to be present' do
      expect(build :institution, institution: nil).not_to be_valid
    end

    it 'requires presence of country' do
      expect(build :institution, country: nil).not_to be_valid
    end
  end
end
