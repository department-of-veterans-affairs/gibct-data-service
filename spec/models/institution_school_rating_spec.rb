# frozen_string_literal: true

require 'rails_helper'
require 'models/shared_examples/shared_examples_for_loadable'
# require 'models/shared_examples/shared_examples_for_exportable'

RSpec.describe InstitutionSchoolRating, type: :model do
  it_behaves_like 'a loadable model', skip_lines: 0
  # broken due to commas in headers
  # TODO: fix error re: commas in headers
  # it_behaves_like 'an exportable model', skip_lines: 0

  describe 'when validating' do
    it 'requires facility_code' do
      expect(build(:school_rating, facility_code: nil)).not_to be_valid
    end
  end
end
