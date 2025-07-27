# frozen_string_literal: true

RSpec.describe ApplicationHelper, type: :helper do
  before do
    allow(helper.controller).to receive(:controller_name).and_return('dashboards')
    allow(helper.controller).to receive(:action_name).and_return('index')
  end

  describe 'controller_label_for_header' do
    it 'returns singular, humanized label in default case' do
      expect(helper.controller_label_for_header).to eq('Dashboard')
    end

    it 'returns specific label if controller is AccrediationTypeKeywords' do
      allow(helper.controller).to receive(:controller_name).and_return('accreditation_type_keywords')
      expect(helper.controller_label_for_header).to eq('Accreditation keyword')
    end

    it 'returns specific label if controller is Uploads' do
      allow(helper.controller).to receive(:controller_name).and_return('uploads')
      expect(helper.controller_label_for_header).to eq('Uploads / Online Changes')
    end

    it 'returns specific label if controller is CalculatorConstants' do
      allow(helper.controller).to receive(:controller_name).and_return('calculator_constants')
      expect(helper.controller_label_for_header).to eq('Calculator constants')
    end
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

  context 'when rendering importmap assets and links' do
    let(:dir_path) { Rails.root.join('app/javascript/controllers/*.js') }
    let(:controller_paths) do
      %w[/gi-bill-data-service/src/app/javascript/controllers/a_controller.js
        /gi-bill-data-service/src/app/javascript/controllers/b_controller.js
        /gi-bill-data-service/src/app/javascript/controllers/c_controller.js]
    end
    let(:hash) { Digest::SHA2.new(256).hexdigest }

    before do
      allow(Dir).to receive(:glob).with(dir_path).and_return(controller_paths)
      controller_paths.each do |path|
        letter = path.match(%r{\/controllers\/([abc])})[1]
        asset_url = "/assets/controllers/#{letter}_controller-#{hash}.js"
        allow(helper).to receive(:asset_path).with("controllers/#{letter}_controller").and_return(asset_url)
      end
    end

    describe 'importmap_controller_assets' do
      it 'returns empty string if no stimulus controllers' do
        allow(Dir).to receive(:glob).with(dir_path).and_return([])
        expect(helper.importmap_controller_assets).to eq('')
      end

      it 'returns import entries for stimulus controllers' do
        str = ",\n        \"controllers/a_controller\": \"/assets/controllers/a_controller-#{hash}.js\"," \
              "\n        \"controllers/b_controller\": \"/assets/controllers/b_controller-#{hash}.js\"," \
              "\n        \"controllers/c_controller\": \"/assets/controllers/c_controller-#{hash}.js\""
        expect(helper.importmap_controller_assets).to eq(str)
      end
    end

    describe 'importmap_controller_links' do
      it 'returns empty string if no stimulus controllers' do
        allow(Dir).to receive(:glob).with(dir_path).and_return([])
        expect(helper.importmap_controller_links).to eq('')
      end

      it 'returns import link tags for stimulus controllers' do
        str = "\n  <link rel=\"modulepreload\" href=\"/assets/controllers/a_controller-#{hash}.js\">" \
              "\n  <link rel=\"modulepreload\" href=\"/assets/controllers/b_controller-#{hash}.js\">" \
              "\n  <link rel=\"modulepreload\" href=\"/assets/controllers/c_controller-#{hash}.js\">"
        expect(helper.importmap_controller_links).to eq(str)
      end
    end
  end
end
