# frozen_string_literal: true
require 'rails_helper'

RSpec.describe InstitutionProfileSerializer, type: :serializer do
  let(:institution) { build :institution }
  let(:institution_with_ope) { build :institution, ope: '"99999999"' }
  let(:data) { JSON.parse(subject)['data'] }
  let(:attributes) { data['attributes'] }
  let(:links) { data['links'] }

  subject { serialize(institution_with_ope, serializer_class: described_class) }

  it 'should include id' do
    expect(data['id'].to_i).to eq(institution_with_ope.id)
  end

  it 'links to vets api' do
    expect(links['vet_website_link']).to_not be_empty
  end

  it "OPE field may have a nil value " do
    expect(institution.ope).to eq(nil)
  end

  it 'OPE value may have a " value in string before parsing' do
    expect(institution_with_ope.ope).to include('"')
  end

  it 'OPE value do not have a " value in string after parsing' do
    expect(data['attributes']['ope']).to_not include('"')
  end

end
