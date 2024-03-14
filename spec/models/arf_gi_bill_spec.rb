# frozen_string_literal: true

require 'rails_helper'
require 'models/shared_examples/shared_examples_for_loadable'
require 'models/shared_examples/shared_examples_for_exportable'

RSpec.describe ArfGiBill, type: :model do
  before { create(:weam) }

  it_behaves_like 'a loadable model', skip_lines: 0
  it_behaves_like 'an exportable model', skip_lines: 0

  describe 'when validating' do
    it 'has a valid factory' do
      arf_gi_bill = build :arf_gi_bill, facility_code: Weam.last.facility_code
      expect(arf_gi_bill).to be_valid
    end

    it 'requires a valid facility_code' do
      expect(build(:arf_gi_bill, facility_code: nil)).not_to be_valid
    end

    it 'requires numeric gibill or blank/nil' do
      expect(build(:arf_gi_bill, gibill: nil, facility_code: Weam.last.facility_code)).to be_valid
      expect(build(:arf_gi_bill, gibill: '', facility_code: Weam.last.facility_code)).to be_valid
      expect(build(:arf_gi_bill, gibill: 'abc', facility_code: Weam.last.facility_code)).not_to be_valid
    end
  end
end
