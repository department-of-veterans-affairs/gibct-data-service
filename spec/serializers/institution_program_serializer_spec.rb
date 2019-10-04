# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InstitutionProgramSerializer, type: :serializer do
  let(:institution_program) { build :institution_program }
  let(:data) { JSON.parse(subject)['data'] }
  let(:attributes) { data['attributes'] }

  subject { serialize(institution_program, serializer_class: described_class) }

  it 'should include program_type' do
    expect(attributes['program_type']).to eq(institution_program.program_type)
  end
  it 'should include description' do
    expect(attributes['description']).to eq(institution_program.description)
  end
  it 'should include length_in_hours' do
    expect(attributes['length_in_hours']).to eq(institution_program.length_in_hours)
  end
  it 'should include facility_code' do
    expect(attributes['facility_code']).to eq(institution_program.facility_code)
  end
  it 'should include institution_name' do
    expect(attributes['institution_name']).to eq(institution_program.institution_name)
  end
  it 'should include city' do
    expect(attributes['city']).to eq(institution_program.city)
  end
  it 'should include state' do
    expect(attributes['state']).to eq(institution_program.state)
  end
  it 'should include country' do
    expect(attributes['country']).to eq(institution_program.country)
  end
  it 'should include preferred_provider' do
    expect(attributes['preferred_provider']).to eq(institution_program.preferred_provider)
  end
  it 'should include tuition_amount' do
    expect(attributes['tuition_amount']).to eq(institution_program.tuition_amount)
  end
  it 'should include va_bah' do
    expect(attributes['va_bah']).to eq(institution_program.va_bah)
  end
  it 'should include dod_bah' do
    expect(attributes['dod_bah']).to eq(institution_program.dod_bah)
  end
end
