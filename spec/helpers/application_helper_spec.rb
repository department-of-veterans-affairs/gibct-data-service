# frozen_string_literal: true
RSpec.describe ApplicationHelper, type: :helper do
  before(:each) do
    allow(helper.controller).to receive(:controller_name).and_return('dashboards')
    allow(helper.controller).to receive(:action_name).and_return('index')
  end

  describe 'active_link?' do
    it 'tells if a link is active' do
      expect(helper.active_link?('/dashboards')).to be_truthy
      expect(helper.active_link?('/blah_blahs')).to be_falsy
    end
  end

  describe 'li_active_class' do
    it 'provides an active css class style for active links' do
      expect(helper.li_active_class('/dashboards')).to eq('active')
    end

    it 'provides an empty string for non-active links' do
      expect(helper.li_active_class('/blah_blahs')).to be_empty
    end
  end

  describe 'link_if_not_active' do
    let(:inactive_link) { %(<a href="/blah_blahs">BlahBlah</a>) }
    let(:active_link) { %(<a>Dashboard</a>) }

    it 'provides an empty string for an active link' do
      expect(helper.link_if_not_active('Dashboard', '/dashboards')).to eq(active_link)
    end

    it 'provides an a tag with href for non-active links' do
      expect(helper.link_if_not_active('BlahBlah', '/blah_blahs')).to eq(inactive_link)
    end
  end
end
