# frozen_string_literal: true

require 'rails_helper'
require 'models/shared_examples/shared_examples_for_loadable'
require 'models/shared_examples/shared_examples_for_exportable'

RSpec.describe P911Tf, type: :model do
  it_behaves_like 'a loadable model', skip_lines: 0
  it_behaves_like 'an exportable model', skip_lines: 0

  describe 'when validating' do
    subject(:p911_tf) { build :p911_tf }

    it 'has a valid factory' do
      expect(p911_tf).to be_valid
    end

    it 'requires a valid facility_code' do
      expect(build(:p911_tf, facility_code: nil)).not_to be_valid
    end

    it 'requires numeric p911_recipients' do
      expect(build(:p911_tf, p911_recipients: nil)).not_to be_valid
      expect(build(:p911_tf, p911_recipients: 'abc')).not_to be_valid
    end

    it 'requires numeric p911_tuition_fees' do
      expect(build(:p911_tf, p911_tuition_fees: nil)).not_to be_valid
      expect(build(:p911_tf, p911_tuition_fees: 'abc')).not_to be_valid
    end
  end
end
