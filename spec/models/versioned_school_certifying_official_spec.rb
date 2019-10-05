# frozen_string_literal: true

require 'rails_helper'
require 'models/shared_examples/shared_examples_for_loadable'
require 'models/shared_examples/shared_examples_for_exportable'

RSpec.describe VersionedSchoolCertifyingOfficial, type: :model do

  describe 'when validating' do
    subject { build :versioned_school_certifying_official }

    it 'has a valid factory' do
      expect(subject).to be_valid
    end
  end
end
