# frozen_string_literal: true

require 'rails_helper'

RSpec.describe VersionedSchoolCertifyingOfficial, type: :model do
  describe 'when validating' do
    subject(versioned_school_certifying_official) { build :versioned_school_certifying_official }

    it 'has a valid factory' do
      expect(versioned_school_certifying_official).to be_valid
    end
  end
end
