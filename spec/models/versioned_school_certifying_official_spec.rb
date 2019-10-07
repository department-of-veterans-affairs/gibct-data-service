# frozen_string_literal: true

require 'rails_helper'

RSpec.describe VersionedSchoolCertifyingOfficial, type: :model do
  describe 'when validating' do
    subject { build :versioned_school_certifying_official }

    it 'has a valid factory' do
      expect(subject).to be_valid
    end
  end
end
