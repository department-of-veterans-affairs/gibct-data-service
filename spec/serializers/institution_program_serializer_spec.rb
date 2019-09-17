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
end
