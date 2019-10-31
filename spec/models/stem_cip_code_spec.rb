# frozen_string_literal: true

require 'rails_helper'
require 'models/shared_examples/shared_examples_for_loadable'
require 'models/shared_examples/shared_examples_for_exportable'

RSpec.describe StemCipCode, type: :model do
  it_behaves_like 'a loadable model', skip_lines: 0
  it_behaves_like 'an exportable model', skip_lines: 0

  describe 'when validating' do
    subject(:stem_cip_code) { build :stem_cip_code }

    it 'has a valid factory' do
      expect(stem_cip_code).to be_valid
    end

    it 'requires a two digit series' do
      expect(build(:stem_cip_code, two_digit_series: nil)).not_to be_valid
    end

    it 'requires a twentyten_cip_code' do
      expect(build(:stem_cip_code, twentyten_cip_code: nil)).not_to be_valid
    end
  end
end
