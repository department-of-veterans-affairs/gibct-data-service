# frozen_string_literal: true

require 'rails_helper'

RSpec.describe YellowRibbonProgramSerializer, type: :serializer do
  subject { serialize(yellow_ribbon_program, serializer_class: described_class) }

  let(:yellow_ribbon_program) { create :yellow_ribbon_program }
  let(:data) { JSON.parse(subject)['data'] }
  let(:attributes) { data['attributes'] }

  before do
    create(:version, :production)
  end

  it 'city' do
    expect(attributes['city']).to eq(yellow_ribbon_program.city)
  end

  it 'country' do
    expect(attributes['country']).to eq(yellow_ribbon_program.country)
  end

  it 'degree_level' do
    expect(attributes['degree_level']).to eq(yellow_ribbon_program.degree_level)
  end

  it 'division_professional_school' do
    expect(attributes['division_professional_school']).to eq(yellow_ribbon_program.division_professional_school)
  end

  it 'facility_code' do
    expect(attributes['facility_code']).to eq(yellow_ribbon_program.facility_code)
  end

  it 'institution_id' do
    expect(attributes['institution_id']).to eq(yellow_ribbon_program.institution_id)
  end

  it 'insturl' do
    expect(attributes['insturl']).to eq(yellow_ribbon_program.insturl)
  end

  it 'number_of_students' do
    expect(attributes['number_of_students']).to eq(yellow_ribbon_program.number_of_students)
  end

  it 'name_of_institution' do
    expect(attributes['name_of_institution']).to eq(yellow_ribbon_program.name_of_institution)
  end

  it 'state' do
    expect(attributes['state']).to eq(yellow_ribbon_program.state)
  end

  it 'street_address' do
    expect(attributes['street_address']).to eq(yellow_ribbon_program.street_address)
  end

end
