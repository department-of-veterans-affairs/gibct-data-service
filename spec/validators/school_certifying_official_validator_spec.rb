# frozen_string_literal: true

require 'rspec'

describe SchoolCertifyingOfficialValidator do
  def check_error_messages(school_certifying_official, error_message)
    error_messages = school_certifying_official.errors.messages
    expect(error_messages.any?).to eq(true)
    expect(error_messages[:base]).to include(error_message)
  end

  describe '#validate' do
    context 'when priority is valid' do
      it 'passes validation' do
        sco = create :school_certifying_official
        expect(sco).to be_valid
      end

      it 'passes validation regardless of casing' do
        sco = create :school_certifying_official, priority: 'priMary'
        expect(sco).to be_valid
      end
    end

    context 'when priority is invalid' do
      it 'fails validation' do
        sco = create :school_certifying_official, :invalid_priority
        expect(sco.valid?(:after_import)).to eq(false)
        check_error_messages(sco, 'Priority is not a valid value.')
      end
    end
  end
end
