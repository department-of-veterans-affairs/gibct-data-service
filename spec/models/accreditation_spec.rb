# frozen_string_literal: true
require 'rails_helper'
require 'models/shared_examples/shared_examples_for_loadable'
require 'models/shared_examples/shared_examples_for_exportable'

RSpec.describe Accreditation, type: :model do
  it_behaves_like 'a loadable model', skip_lines: 0
  it_behaves_like 'an exportable model', skip_lines: 0

  describe 'when validating' do
    subject { Accreditation.new(attributes_for(:accreditation)) }

    let(:by_campus) { Accreditation.create(attributes_for(:accreditation, :by_campus)) }
    let(:by_institution) { Accreditation.create(attributes_for(:accreditation, :by_institution)) }

    it 'has a valid factory' do
      expect(subject).to be_valid
    end

    it 'sets the ope6' do
      subject.valid?
      expect(subject.ope6).to eq(subject.ope[1, 5])
    end

    it 'will use either the institution_name or the campus_name if only one is present' do
      expect(by_campus.institution).to eq(by_campus.campus_name)
      expect(by_institution.institution).to eq(by_institution.institution_name)
    end

    it 'prefers campus_name over institution_name' do
      subject.valid?
      expect(subject.institution).to eq(subject.campus_name)
    end

    it 'will use either the institution_ipeds_unitid or the campus_ipeds_unitid if only one is present' do
      expect(by_campus.cross).to eq(by_campus.campus_ipeds_unitid)
      expect(by_institution.cross).to eq(by_institution.institution_ipeds_unitid)
    end

    it 'prefers campus_ipeds_unitid over institution_ipeds_unitid' do
      subject.valid?
      expect(subject.cross).to eq(subject.campus_ipeds_unitid)
    end

    it 'assigns the accreditation_type based on agency name' do
      described_class::ACCREDITATIONS.keys.each do |type|
        described_class::ACCREDITATIONS[type]
          .map { |regexp| "THE #{regexp.to_s.scan(/:(.*)\)/).flatten.first.upcase} ONE" }
          .each do |name|
          a = Accreditation.create(attributes_for(:accreditation, agency_name: name))
          expect(a.accreditation_type).to eq(type)
        end
      end
    end
  end
end
