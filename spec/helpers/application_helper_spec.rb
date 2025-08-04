# frozen_string_literal: true

RSpec.describe ApplicationHelper, type: :helper do
  before do
    allow(helper.controller).to receive(:controller_name).and_return('dashboards')
    allow(helper.controller).to receive(:action_name).and_return('index')
  end

  describe 'active_link?' do
    it 'tells if a link is active' do
      expect(helper).to be_active_link('/dashboards')
      expect(helper).not_to be_active_link('/blah_blahs')
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

  describe 'pretty_error' do
    let(:errors) { %w[error1 error2] }
    let(:label) { 'some label' }

    let(:ul) { '<ul><li>error1</li><li>error2</li></ul>' }
    let(:ul_with_label) { '<p>some label</p>' + ul }
    let(:label_alone) { '<p>some label</p>' }

    def div_helper(inner)
      '<div class="errors">' + inner + '</div>'
    end

    context 'without a label' do
      it 'formats the errors for html' do
        expect(helper.pretty_error(errors)).to eq(div_helper(ul))
      end

      it 'returns an empty string when there are no errors' do
        expect(helper.pretty_error([])).to be_blank
      end
    end

    context 'with a label' do
      it 'formats the errors for html' do
        expect(helper.pretty_error(errors, label)).to eq(div_helper(ul_with_label))
      end

      it 'returns the label when there are no errors' do
        expect(helper.pretty_error([], label)).to eq(div_helper(label_alone))
      end
    end
  end
end
