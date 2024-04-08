# frozen_string_literal: true

require 'rails_helper'

RSpec.describe YellowRibbonProgramSerializer, type: :serializer do
  subject { serialize(yellow_ribbon_program, serializer_class: described_class) }

  let(:yellow_ribbon_program) { create :yellow_ribbon_program, institution_id: Institution.last.id }
  let(:data) { JSON.parse(subject)['data'] }
  let(:attributes) { data['attributes'] }

  before do
    v = create(:version, :production)
    create(:institution, version_id: v.id)
  end

  it 'city' do
    expect(attributes['city']).to eq(yellow_ribbon_program.city)
  end

  it 'country' do
    expect(attributes['country']).to eq(yellow_ribbon_program.country)
  end

  it 'correspondence' do
    expect(attributes['correspondence']).to eq(yellow_ribbon_program.correspondence)
  end

  it 'degree_level' do
    expect(attributes['degree_level']).to eq(yellow_ribbon_program.degree_level)
  end

  it 'distance_learning' do
    expect(attributes['distance_learning']).to eq(yellow_ribbon_program.distance_learning)
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

  it 'latitude' do
    expect(attributes['latitude']).to eq(yellow_ribbon_program.latitude)
  end

  it 'longitude' do
    expect(attributes['longitude']).to eq(yellow_ribbon_program.longitude)
  end

  it 'number_of_students' do
    expect(attributes['number_of_students']).to eq(yellow_ribbon_program.number_of_students)
  end

  it 'name_of_institution' do
    expect(attributes['name_of_institution']).to eq(yellow_ribbon_program.name_of_institution)
  end

  it 'online_only' do
    expect(attributes['online_only']).to eq(yellow_ribbon_program.online_only)
  end

  it 'state' do
    expect(attributes['state']).to eq(yellow_ribbon_program.state)
  end

  it 'street_address' do
    expect(attributes['street_address']).to eq(yellow_ribbon_program.street_address)
  end

  it 'student_veteran' do
    expect(attributes['student_veteran']).to eq(yellow_ribbon_program.student_veteran)
  end

  it 'student_veteran_link' do
    expect(attributes['student_veteran_link']).to eq(yellow_ribbon_program.student_veteran_link)
  end

  it 'ungeocodable' do
    expect(attributes['ungeocodable']).to eq(yellow_ribbon_program.ungeocodable)
  end

  it 'year_of_yr_participation' do
    expect(attributes['year_of_yr_participation']).to eq(yellow_ribbon_program.year_of_yr_participation)
  end

  it 'zip' do
    expect(attributes['zip']).to eq(yellow_ribbon_program.zip)
  end
end
