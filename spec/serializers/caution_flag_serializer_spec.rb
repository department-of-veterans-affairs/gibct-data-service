# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CautionFlagSerializer, type: :serializer do
  subject { serialize(caution_flag, serializer_class: described_class) }

  let (:preview_version) { create :version, :preview }
  let (:institution) { create :institution, version_id: preview_version.id }

  # rubocop:disable Layout/LineLength
  let(:caution_flag) { create :caution_flag, :accreditation_issue, institution_id: institution.id, version_id: preview_version.id }
  # rubocop:enable Layout/LineLength

  let(:data) { JSON.parse(subject)['data'] }
  let(:attributes) { data['attributes'] }

  it 'includes title' do
    expect(attributes['title']).to eq(caution_flag.title)
  end

  it 'includes description' do
    expect(attributes['description']).to eq(caution_flag.description)
  end

  it 'includes link_text' do
    expect(attributes['link_text']).to eq(caution_flag.link_text)
  end

  it 'includes link_url' do
    expect(attributes['link_url']).to eq(caution_flag.link_url)
  end
end
