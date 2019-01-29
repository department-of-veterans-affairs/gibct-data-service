# frozen_string_literal: true

require 'rails_helper'
require 'models/shared_examples/shared_examples_for_loadable'
require 'models/shared_examples/shared_examples_for_exportable'

RSpec.describe AccreditationRecord, type: :model do
  it_behaves_like 'a loadable model', skip_lines: 0
  it_behaves_like 'an exportable model', skip_lines: 0

  describe 'when validating' do
    subject { build :accreditation_record }

    it 'has a valid factory' do
      expect(subject).to be_valid
    end

    it 'determines the `accreditation_type` from the agency_name' do
      expect(subject.accreditation_type).to eq('regional')
    end
  end
end
