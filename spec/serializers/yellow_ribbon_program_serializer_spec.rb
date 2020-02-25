# frozen_string_literal: true

require 'rails_helper'

RSpec.describe YellowRibbonProgramSerializer, type: :serializer do
  subject { serialize(yellow_ribbon_program, serializer_class: described_class) }

  let(:yellow_ribbon_program) { create :yellow_ribbon_program }
  let(:data) { JSON.parse(subject)['data'] }
  let(:attributes) { data['attributes'] }

  it 'includes city' do
    expect(attributes['city']).to eq(yellow_ribbon_program.city)
  end

  it 'includes degree_level' do
    expect(attributes['degree_level']).to eq(yellow_ribbon_program.degree_level)
  end

  it 'includes division_professional_school' do
    expect(attributes['division_professional_school']).to eq(yellow_ribbon_program.division_professional_school)
  end

  it 'includes facility_code' do
    expect(attributes['facility_code']).to eq(yellow_ribbon_program.facility_code)
  end

  it 'includes number_of_students' do
    expect(attributes['number_of_students']).to eq(yellow_ribbon_program.number_of_students)
  end

  it 'includes school_name_in_yr_database' do
    expect(attributes['school_name_in_yr_database']).to eq(yellow_ribbon_program.school_name_in_yr_database)
  end

  it 'includes state' do
    expect(attributes['state']).to eq(yellow_ribbon_program.state)
  end

  it 'includes street_address' do
    expect(attributes['street_address']).to eq(yellow_ribbon_program.street_address)
  end

  it 'includes zip' do
    expect(attributes['zip']).to eq(yellow_ribbon_program.zip)
  end
end
