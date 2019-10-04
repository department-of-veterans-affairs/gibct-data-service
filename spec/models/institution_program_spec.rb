# frozen_string_literal: true

require 'rails_helper'
require 'models/shared_examples/shared_examples_for_loadable'
require 'models/shared_examples/shared_examples_for_exportable'

RSpec.describe InstitutionProgram, type: :model do
  describe 'when importing or exporting' do
    before(:each) { create :version, production: false }
  end

  describe 'when validating' do
    subject { create :institution_program }

    it 'has a valid factory' do
      expect(subject).to be_valid
    end

    it 'requires a version' do
      expect(build(:institution, version: nil)).not_to be_valid
    end

    it 'requires a facility code' do
      expect(build(:institution_program, facility_code: nil)).not_to be_valid
    end

    it 'requires an institution name' do
      expect(build(:institution_program, institution_name: nil)).not_to be_valid
    end

    it 'requires a description' do
      expect(build(:institution_program, description: nil)).not_to be_valid
    end
  end

  describe 'class methods and scopes' do
    context 'version' do
      it 'should retrieve institutions by a specific version number' do
        i = create_list :institution_program, 2, version: 1
        j = create_list :institution_program, 2, version: 2

        expect(InstitutionProgram.version(i.first.version)).to match_array(i.to_a)
        expect(InstitutionProgram.version(j.first.version)).to match_array(j.to_a)
      end

      it 'returns blank if a nil or non-existent version number is supplied' do
        create :institution_program

        expect(InstitutionProgram.version(-1)).to eq([])
        expect(InstitutionProgram.version(nil)).to eq([])
      end
    end

    context 'filter scope' do
      it 'should raise an error if no arguments are provided' do
        expect { described_class.filter }.to raise_error(ArgumentError)
      end

      it 'should filter on field existing' do
        expect(described_class.filter('description', 'true').to_sql)
          .to include("WHERE \"institution_programs\".\"description\" = 't'")
      end

      it 'should filter on field not existing' do
        expect(described_class.filter('description', 'false').to_sql)
          .to include("WHERE (\"institution_programs\".\"description\" != 't')")
      end
    end

    context 'search scope' do
      it 'should return nil if no search term is provided' do
        expect(described_class.search(nil)).to be_empty
      end
    end
  end
end
