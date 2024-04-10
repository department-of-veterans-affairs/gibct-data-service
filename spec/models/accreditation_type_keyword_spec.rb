# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccreditationTypeKeyword, type: :model do
  describe 'when validating' do
    let(:accreditation_type_keyword) { build :accreditation_type_keyword }

    it 'has a valid factory' do
      expect(accreditation_type_keyword).to be_valid
    end

    it 'requires a accreditation_type' do
      accreditation_type_keyword.accreditation_type = nil
      expect(accreditation_type_keyword).not_to be_valid
    end

    it 'requires a keyword_match' do
      accreditation_type_keyword.keyword_match = nil
      expect(accreditation_type_keyword).not_to be_valid
    end

    it 'has one of the defined accreditation_types' do
      expect(AccreditationTypeKeyword::ACCREDITATION_TYPES).to include(accreditation_type_keyword.accreditation_type)
    end

    it 'requires uniqueness' do
      accreditation_type_keyword.save
      same_accreditation_type_keyword = accreditation_type_keyword.dup

      expect(same_accreditation_type_keyword).not_to be_valid
    end

    it 'is case insensitive when validating for uniqueness' do
      accreditation_type_keyword.save
      same_accreditation_type_keyword = accreditation_type_keyword.dup
      same_accreditation_type_keyword.keyword_match.upcase!

      expect(same_accreditation_type_keyword).not_to be_valid

      same_accreditation_type_keyword = accreditation_type_keyword.dup
      same_accreditation_type_keyword.keyword_match.capitalize!

      expect(same_accreditation_type_keyword).not_to be_valid
    end
  end

  describe 'when creating' do
    let(:accreditation_type_keyword) { build :accreditation_type_keyword }

    it 'increments the count by 1' do
      accreditation_type_keyword.save

      expect(described_class.count).to eq(1)
    end

    it 'saves the keyword_match downcased' do
      accreditation_type_keyword.keyword_match.upcase!
      accreditation_type_keyword.save

      atk = described_class.first # Pull it from the database to be sure

      expect(atk.keyword_match).to eq('middle')
    end
  end

  describe 'when deleting' do
    let(:accreditation_type_keyword) { create :accreditation_type_keyword }
    let(:accreditation_institute_campus) { create(:accreditation_institute_campus) }
    let(:accreditation_record) { build :accreditation_record }

    it 'nils the accreditation_type_keyword_id on accreditation records that reference it' do
      accreditation_record.accreditation_type_keyword = accreditation_type_keyword
      accreditation_record.accreditation_institute_campus = accreditation_institute_campus
      accreditation_record.save

      # confirm it took
      expect(accreditation_record.type_of_accreditation).to eq('regional')
      accreditation_type_keyword.destroy
      # force a reload which begs the question do we need inverse_of on these?
      ar = AccreditationRecord.find(accreditation_record.id)
      expect(ar.type_of_accreditation).to be_nil
    end
  end
end
