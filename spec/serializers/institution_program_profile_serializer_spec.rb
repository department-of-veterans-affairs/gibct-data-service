# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InstitutionProgramProfileSerializer, type: :serializer do
  subject { serialize(institution_program, serializer_class: described_class) }

  let(:institution_program) { create :institution_program, :in_nyc }
  let(:data) { JSON.parse(subject)['data'] }
  let(:attributes) { data['attributes'] }

  it 'includes program_type' do
    expect(attributes['program_type']).to eq(institution_program.program_type)
  end

  it 'includes description' do
    expect(attributes['description']).to eq(institution_program.description)
  end

  it 'includes length_in_hours' do
    expect(attributes['length_in_hours']).to eq(institution_program.length_in_hours)
  end

  it 'includes length_in_weeks' do
    expect(attributes['length_in_weeks']).to eq(institution_program.length_in_weeks)
  end

  it 'includes provider_website' do
    expect(attributes['provider_website']).to eq(institution_program.provider_website)
  end

  it 'includes phone_area_code' do
    expect(attributes['phone_area_code']).to eq(institution_program.phone_area_code)
  end

  it 'includes phone_number' do
    expect(attributes['phone_number']).to eq(institution_program.phone_number)
  end

  it 'includes school_locale' do
    expect(attributes['school_locale']).to eq(institution_program.school_locale)
  end

  it 'includes tuition_amount' do
    expect(attributes['tuition_amount']).to eq(institution_program.tuition_amount)
  end

  it 'includes va_bah' do
    expect(attributes['va_bah']).to eq(institution_program.va_bah)
  end

  it 'includes dod_bah' do
    expect(attributes['dod_bah']).to eq(institution_program.dod_bah)
  end

  it 'includes provider_email_address' do
    expect(attributes['provider_email_address']).to eq(institution_program.provider_email_address)
  end

  it 'includes student_vet_group' do
    expect(attributes['student_vet_group']).to eq(institution_program.student_vet_group)
  end

  it 'includes student_vet_group_website' do
    expect(attributes['student_vet_group_website']).to eq(institution_program.student_vet_group_website)
  end

  it 'includes vet_success_name' do
    expect(attributes['vet_success_name']).to eq(institution_program.vet_success_name)
  end

  it 'includes vet_success_email' do
    expect(attributes['vet_success_email']).to eq(institution_program.vet_success_email)
  end
end
