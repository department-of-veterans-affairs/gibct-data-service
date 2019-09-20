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
  it 'should include full_time_undergraduate' do
    expect(attributes['full_time_undergraduate']).to eq(institution_program.full_time_undergraduate)
  end
  it 'should include graduate' do
    expect(attributes['graduate']).to eq(institution_program.graduate)
  end
  it 'should include full_time_modifier' do
    expect(attributes['full_time_modifier']).to eq(institution_program.full_time_modifier)
  end
  it 'should include length' do
    expect(attributes['length']).to eq(institution_program.length)
  end
  it 'should include school_locale' do
    expect(attributes['school_locale']).to eq(institution_program.school_locale)
  end
  it 'should include provider_website' do
    expect(attributes['provider_website']).to eq(institution_program.provider_website)
  end
  it 'should include provider_email_address' do
    expect(attributes['provider_email_address']).to eq(institution_program.provider_email_address)
  end
  it 'should include phone_area_code' do
    expect(attributes['phone_area_code']).to eq(institution_program.phone_area_code)
  end
  it 'should include phone_number' do
    expect(attributes['phone_number']).to eq(institution_program.phone_number)
  end
  it 'should include student_vet_group' do
    expect(attributes['student_vet_group']).to eq(institution_program.student_vet_group)
  end
  it 'should include student_vet_group_website' do
    expect(attributes['student_vet_group_website']).to eq(institution_program.student_vet_group_website)
  end
  it 'should include vet_success_name' do
    expect(attributes['vet_success_name']).to eq(institution_program.vet_success_name)
  end
  it 'should include vet_success_email' do
    expect(attributes['vet_success_email']).to eq(institution_program.vet_success_email)
  end
  it 'should include tuition_amount' do
    expect(attributes['tuition_amount']).to eq(institution_program.tuition_amount)
  end
  it 'should include program_length' do
    expect(attributes['program_length']).to eq(institution_program.program_length)
  end
end
