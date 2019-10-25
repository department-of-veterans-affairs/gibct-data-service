# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InstitutionProgram, type: :model do
  describe 'when validating' do
    subject { create :institution_program, institution: institution }

    let(:institution) { create :institution, :physical_address }

    it 'has a valid factory' do
      expect(subject).to be_valid
    end

    it 'requires a version' do
      expect(build(:institution_program, institution: institution, version: nil)).not_to be_valid
    end

    it 'requires an institution' do
      expect(build(:institution_program, institution: nil)).not_to be_valid
    end

    it 'requires a description' do
      expect(build(:institution_program, institution: institution, description: nil)).not_to be_valid
    end
  end

  describe 'autocomplete' do
    context 'when search term is program name' do
      it 'returns collection of programs with program name matches' do
        create(:institution_program)
        create_list(:institution_program, 2, :start_like_harv)
        expect(described_class.autocomplete('harv').length).to eq(2)
      end

      it 'limits results' do
        create_list(:institution_program, 2, :start_like_harv)
        expect(described_class.autocomplete('harv', 1).length).to eq(1)
      end
    end

    context 'when search term is institution name' do
      it 'returns collection of programs with institution name matches' do
        program = create(:institution_program)
        create_list(:institution_program, 2, :start_like_harv)
        result = described_class.autocomplete(program.institution_name)
        expect(result.length).to eq(1)
        expect(result.first.id).to eq(program.id)
      end
    end
  end

  describe 'class methods and scopes' do
    context 'version' do
      let(:institution) { create :institution, :physical_address }

      it 'retrieves institutions by a specific version number' do
        i = create_list :institution_program, 2, version: 1, institution: institution
        j = create_list :institution_program, 2, version: 2, institution: institution

        expect(described_class.version(i.first.version)).to match_array(i.to_a)
        expect(described_class.version(j.first.version)).to match_array(j.to_a)
      end

      it 'returns blank if a nil or non-existent version number is supplied' do
        create :institution_program, institution: institution

        expect(described_class.version(-1)).to eq([])
        expect(described_class.version(nil)).to eq([])
      end
    end

    context 'filter scope' do
      it 'raises an error if no arguments are provided' do
        expect { described_class.filter }.to raise_error(ArgumentError)
      end

      it 'filters on field existing' do
        expect(described_class.filter('description', 'true').to_sql)
          .to include("WHERE \"institution_programs\".\"description\" = 't'")
      end

      it 'filters on field not existing' do
        expect(described_class.filter('description', 'false').to_sql)
          .to include("WHERE \"institution_programs\".\"description\" != 't'")
      end
    end

    context 'search scope' do
      it 'returns nil if no search term is provided' do
        expect(described_class.search(nil)).to be_empty
      end
    end
  end
end
