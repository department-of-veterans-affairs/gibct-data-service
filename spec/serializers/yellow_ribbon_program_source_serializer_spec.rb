# frozen_string_literal: true

require 'rails_helper'

RSpec.describe YellowRibbonProgramSourceSerializer, type: :serializer do
  subject { serialize(yellow_ribbon_program_source, serializer_class: described_class) }

  let(:yellow_ribbon_program_source) { create :yellow_ribbon_program_source }
  let(:data) { JSON.parse(subject)['data'] }
  let(:attributes) { data['attributes'] }

  it 'includes city' do
    expect(attributes['city']).to eq(yellow_ribbon_program_source.city)
  end

  it 'includes contribution_amount' do
    expect(attributes['contribution_amount']).to eq(yellow_ribbon_program_source.contribution_amount)
  end

  it 'includes degree_level' do
    expect(attributes['degree_level']).to eq(yellow_ribbon_program_source.degree_level)
  end

  it 'includes division_professional_school' do
    expect(attributes['division_professional_school']).to eq(yellow_ribbon_program_source.division_professional_school)
  end

  it 'includes facility_code' do
    expect(attributes['facility_code']).to eq(yellow_ribbon_program_source.facility_code)
  end

  it 'includes number_of_students' do
    expect(attributes['number_of_students']).to eq(yellow_ribbon_program_source.number_of_students)
  end

  it 'includes school_name_in_yr_database' do
    expect(attributes['school_name_in_yr_database']).to eq(yellow_ribbon_program_source.school_name_in_yr_database)
  end

  it 'includes state' do
    expect(attributes['state']).to eq(yellow_ribbon_program_source.state)
  end

  it 'includes street_address' do
    expect(attributes['street_address']).to eq(yellow_ribbon_program_source.street_address)
  end

  it 'includes zip' do
    expect(attributes['zip']).to eq(yellow_ribbon_program_source.zip)
  end

end
