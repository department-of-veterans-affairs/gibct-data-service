# frozen_string_literal: true

require 'rails_helper'
require 'models/shared_examples/shared_examples_for_loadable'
require 'models/shared_examples/shared_examples_for_exportable'

RSpec.describe SchoolRating, type: :model do
  # it_behaves_like 'a loadable model', skip_lines: 0
  # it_behaves_like 'an exportable model', skip_lines: 0

  describe 'when validating' do\
    it 'has a valid factory' do
      expect(build(:school_rating)).to be_valid
    end

    # it 'requires a valid facility_code' do
    #   expect(build(:post911_stat, facility_code: nil)).not_to be_valid
    # end
    #
    # it 'requires numeric tuition_and_fee_count' do
    #   expect(build(:post911_stat, tuition_and_fee_count: nil)).to be_valid
    #   expect(build(:post911_stat, tuition_and_fee_count: 'abc')).not_to be_valid
    # end
    #
    # it 'requires numeric tuition_and_fee_total_amount' do
    #   expect(build(:post911_stat, tuition_and_fee_total_amount: nil)).to be_valid
    #   expect(build(:post911_stat, tuition_and_fee_total_amount: 'abc')).not_to be_valid
    # end
    #
    # it 'requires numeric yellow_ribbon_count' do
    #   expect(build(:post911_stat, yellow_ribbon_count: nil)).to be_valid
    #   expect(build(:post911_stat, yellow_ribbon_count: 'abc')).not_to be_valid
    # end
    #
    # it 'requires numeric yellow_ribbon_total_amount' do
    #   expect(build(:post911_stat, yellow_ribbon_total_amount: nil)).to be_valid
    #   expect(build(:post911_stat, yellow_ribbon_total_amount: 'abc')).not_to be_valid
    # end
  end
end
