# frozen_string_literal: true
require 'rails_helper'

RSpec.describe InstitutionProfileSerializer, type: :serializer do
  let(:institution) { build :institution }
  let(:data) { JSON.parse(subject)['data'] }
  let(:attributes) { data['attributes'] }
  let(:links) { data['links'] }

  subject { serialize(institution, serializer_class: described_class) }

  it 'should include id' do
    expect(data['id'].to_i).to eq(institution.id)
  end

  it 'links to vets api' do
    expect(links['vet_website_link']).to_not be_empty
  end

  it 'should include OPE value' do
    expect(data['attributes']['ope']).to eq(institution.ope)
  end
end
