# frozen_string_literal: true

require 'rails_helper'
require 'models/shared_examples/shared_examples_for_loadable'
require 'models/shared_examples/shared_examples_for_exportable'

RSpec.describe ArfGiBill, type: :model do
  before do
    create(:weam, facility_code: '11000101')
    create(:weam, facility_code: '11000201')
  end

  it_behaves_like 'a loadable model', skip_lines: 0
  it_behaves_like 'an exportable model', skip_lines: 0

  describe 'when validating' do
    subject(:arf_gi_bill) { build :arf_gi_bill, facility_code: Weam.last.facility_code }

    it 'has a valid factory' do
      expect(arf_gi_bill).to be_valid
    end

    it 'requires a valid facility_code' do
      expect(build(:arf_gi_bill, facility_code: nil)).not_to be_valid
    end

    it 'requires numeric gibill or nil' do
      expect(build(:arf_gi_bill, facility_code: Weam.last.facility_code, gibill: nil)).to be_valid
      expect(build(:arf_gi_bill, facility_code: Weam.last.facility_code, gibill: 'abc')).not_to be_valid
    end
  end
end
