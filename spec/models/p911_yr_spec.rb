# frozen_string_literal: true
require 'rails_helper'
require 'models/shared_examples/shared_examples_for_loadable'
require 'models/shared_examples/shared_examples_for_exportable'

RSpec.describe P911Yr, type: :model do
  it_behaves_like 'a loadable model', skip_lines: 0
  it_behaves_like 'an exportable model', skip_lines: 0

  describe 'when validating' do
    subject { build :p911_yr }

    it 'has a valid factory' do
      expect(subject).to be_valid
    end

    it 'requires a valid facility_code' do
      expect(build(:p911_yr, facility_code: nil)).not_to be_valid
    end

    it 'requires numeric p911_yr_recipients' do
      expect(build(:p911_yr, p911_yr_recipients: nil)).not_to be_valid
      expect(build(:p911_yr, p911_yr_recipients: 'abc')).not_to be_valid
    end

    it 'requires numeric p911_yellow_ribbon' do
      expect(build(:p911_yr, p911_yellow_ribbon: nil)).not_to be_valid
      expect(build(:p911_yr, p911_yellow_ribbon: 'abc')).not_to be_valid
    end
  end
end
