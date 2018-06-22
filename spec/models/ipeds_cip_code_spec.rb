# frozen_string_literal: true

require 'rails_helper'
require 'models/shared_examples/shared_examples_for_loadable'
require 'models/shared_examples/shared_examples_for_exportable'

RSpec.describe IpedsCipCode, type: :model do
  it_behaves_like 'a loadable model', skip_lines: 0
  it_behaves_like 'an exportable model', skip_lines: 0

  describe 'when validating' do
    subject { build :ipeds_cip_code }

    it 'has a valid factory' do
      expect(subject).to be_valid
    end

    it 'requires a cross reference (unitid)' do
      expect(build(:ipeds_cip_code, cross: nil)).not_to be_valid
    end

    it 'requires a cipcode' do
      expect(build(:ipeds_cip_code, cipcode: nil)).not_to be_valid
    end

    it 'requires a numeric ctotalt' do
      expect(build(:ipeds_cip_code, ctotalt: 'abc')).not_to be_valid
    end
  end
end
