# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CautionFlagSerializer, type: :serializer do
  subject { serialize(caution_flag, serializer_class: described_class) }

  before do
    create(:version, :prod_vsn_w_inst_accr_iss_caution_flag)
  end

  let(:caution_flag) { CautionFlag.last }
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
