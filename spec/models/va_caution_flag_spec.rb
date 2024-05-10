# frozen_string_literal: true

require 'rails_helper'
require 'models/shared_examples/shared_examples_for_loadable'
require 'models/shared_examples/shared_examples_for_exportable'

RSpec.describe VaCautionFlag, type: :model do
  it_behaves_like 'a loadable model', skip_lines: 0
  it_behaves_like 'an exportable model', skip_lines: 0

  describe 'when validating' do
    subject(:va_caution_flag) { build :va_caution_flag }

    it 'has a valid factory' do
      expect(va_caution_flag).to be_valid
    end

    it 'requires a facility code' do
      expect(build(:va_caution_flag, facility_code: nil)).not_to be_valid
    end

    it 'allows nil settlement date' do
      expect(build(:va_caution_flag, settlement_date: nil)).to be_valid
    end

    it 'requires settlement date to be in the format mm/dd/yy if present' do
      expect(build(:va_caution_flag, settlement_date: '2024-01-01')).not_to be_valid
    end

    it 'allows nil school closing date' do
      expect(build(:va_caution_flag, school_closing_date: nil)).to be_valid
    end

    it 'requires school closing date to be in the format mm/dd/yy if present' do
      expect(build(:va_caution_flag, school_closing_date: '2024-01-01')).not_to be_valid
    end
  end
end