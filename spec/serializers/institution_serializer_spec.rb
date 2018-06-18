# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InstitutionSerializer, type: :serializer do
  let(:institution) { build :institution }
  let(:data) { JSON.parse(subject)['data'] }
  let(:attributes) { data['attributes'] }
  let(:links) { data['links'] }

  subject { serialize(institution, serializer_class: described_class) }

  it 'should include id' do
    expect(data['id'].to_i).to eq(institution.id)
  end

  it 'links to the college scorecard' do
    expect(links['scorecard']).to_not be_empty
  end

  it 'links to its website' do
    expect(links['website']).to_not be_empty
  end

  it 'links to its detailed profile data' do
    expect(links['self']).to_not be_empty
  end
end
