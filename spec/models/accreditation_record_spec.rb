# frozen_string_literal: true

require 'rails_helper'
require 'models/shared_examples/shared_examples_for_loadable'
require 'models/shared_examples/shared_examples_for_exportable'

RSpec.describe AccreditationRecord, type: :model do
  it_behaves_like 'a loadable model', skip_lines: 0
  it_behaves_like 'an exportable model', skip_lines: 0

  describe 'when validating' do
    subject(:accreditation_record) { build :accreditation_record }

    it 'has a valid factory' do
      expect(accreditation_record).to be_valid
    end
  end

  describe 'it sets the accreditation type depending on the agency name' do
    context 'with regional accreditation' do
      subject(:accreditation_record) { build :regional_accreditation_type }

      before { create(:accreditation_type_keyword, :accreditation_type_regional) }

      it 'assigns regional to accreditation_type' do
        expect(accreditation_record.accreditation_type).to eq('regional')
      end
    end

    context 'with national accreditation' do
      subject(:accreditation_record) { build :national_accreditation_type }

      before { create(:accreditation_type_keyword, :accreditation_type_national) }

      it 'assigns national to accreditation_type' do
        expect(accreditation_record.accreditation_type).to eq('national')
      end
    end

    context 'with hybrid accreditation' do
      subject(:accreditation_record) { build :hybrid_accreditation_type }

      before { create(:accreditation_type_keyword, :accreditation_type_hybrid) }

      it 'assigns hybrid to accreditation_type' do
        expect(accreditation_record.accreditation_type).to eq('hybrid')
      end
    end

    context 'with unaccreditable' do
      subject(:accreditation_record) { build :nil_accreditation_type }

      it 'does not assign an accreditation type' do
        expect(accreditation_record.accreditation_type).to be_nil
      end
    end

    context 'with a match in multiple accreditation types' do
      subject(:accreditation_record) { build :national_accreditation_type }

      before do
        create(:accreditation_type_keyword, :accreditation_type_national)
        create(:accreditation_type_keyword, :hybrid_career_schools)
      end

      it 'assigns the first matching type to the accreditation type' do
        expect(accreditation_record.accreditation_type).to eq('national')
      end
    end
  end
end
