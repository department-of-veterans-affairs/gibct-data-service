# frozen_string_literal: true

require 'rails_helper'
require 'models/shared_examples/shared_examples_for_loadable'
require 'models/shared_examples/shared_examples_for_exportable'

RSpec.describe SchoolClosure, type: :model do
  it_behaves_like 'a loadable model', skip_lines: 0
  it_behaves_like 'an exportable model', skip_lines: 0

  describe 'when validating' do
    subject { build :school_closure }

    it 'has a valid factory' do
      expect(subject).to be_valid
    end

    it 'requires a valid facility_code' do
      expect(build(:school_closure, facility_code: nil)).not_to be_valid
    end

    it 'requires a date when closing' do
      expect(build(:school_closure, school_closing: true, school_closing_on: nil)).not_to be_valid
    end

    it 'checks school closing date is nil if school is not closing' do
      expect(build(:school_closure, school_closing: false, school_closing_on: Time.zone.today)).not_to be_valid
    end
  end
end
