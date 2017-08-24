# frozen_string_literal: true
require 'rails_helper'

RSpec.describe GibctSiteMapper, type: :model do
  subject { GibctSiteMapper.new(ping: false) }

  let(:preview_version) { Version.current_preview }
  let(:production_version) { Version.current_production }
  let(:sitemaps_path) { File.join(Rails.root, 'public', 'sitemap.xml.gz') }

  before(:each) do
    File.delete(sitemaps_path) if File.exist?(sitemaps_path)

    [:preview, :production].each { |p| create :version, p }
    [preview_version, production_version].each { |p| create :institution, version: p.number }
  end

  describe 'when initializing' do
    it 'gets the latest production version' do
      expect(subject.version).to eq(Version.current_production.number)
    end
  end
end
