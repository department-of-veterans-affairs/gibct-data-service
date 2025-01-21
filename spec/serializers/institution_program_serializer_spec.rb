# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InstitutionProgramSerializer, type: :serializer do
  subject { serialize(institution_program, serializer_class: described_class) }

  let(:institution_program) { create :institution_program, :in_nyc }
  let(:data) { JSON.parse(subject)['data'] }
  let(:attributes) { data['attributes'] }

  before do
    create(:version, :production)
  end

  it 'includes program_type' do
    expect(attributes['program_type']).to eq(institution_program.program_type)
  end

  it 'includes description' do
    expect(attributes['description']).to eq(institution_program.description)
  end

  it 'includes facility_code' do
    expect(attributes['facility_code']).to eq(institution_program.facility_code)
  end

  it 'includes institution_name' do
    expect(attributes['institution_name']).to eq(institution_program.institution_name)
  end

  it 'includes city' do
    expect(attributes['city']).to eq(institution_program.city)
  end

  it 'includes state' do
    expect(attributes['state']).to eq(institution_program.state)
  end

  it 'includes country' do
    expect(attributes['country']).to eq(institution_program.country)
  end

  it 'includes preferred_provider' do
    expect(attributes['preferred_provider']).to eq(institution_program.preferred_provider)
  end

  it 'includes va_bah' do
    expect(attributes['va_bah']).to eq(institution_program.va_bah)
  end

  it 'includes dod_bah' do
    expect(attributes['dod_bah']).to eq(institution_program.dod_bah)
  end

  it 'includes school_closing' do
    expect(attributes['school_closing']).to eq(institution_program.school_closing)
  end

  it 'includes caution_flags' do
    expect(attributes['caution_flags']).to eq(institution_program.caution_flags)
  end

  it 'includes ojt_app_type' do
    expect(attributes['ojt_app_type']).to eq(institution_program.ojt_app_type)
  end
end
