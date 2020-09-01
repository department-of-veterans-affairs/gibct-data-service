# frozen_string_literal: true

require 'rails_helper'
require 'models/shared_examples/shared_examples_for_loadable'
require 'models/shared_examples/shared_examples_for_exportable'

RSpec.describe SchoolRating, type: :model do
  it_behaves_like 'a loadable model', skip_lines: 0
  it_behaves_like 'an exportable model', skip_lines: 0

  describe 'when validating' do\
    it 'has a valid factory' do
      expect(build(:school_rating)).to be_valid
    end

    it 'requires facility_code' do
      expect(build(:school_rating, facility_code: nil)).not_to be_valid
    end

    it 'requires rater_id' do
      expect(build(:school_rating, rater_id: nil)).not_to be_valid
    end

    it 'requires rated_on' do
      expect(build(:school_rating, rated_on: nil)).not_to be_valid
    end
  end
end
