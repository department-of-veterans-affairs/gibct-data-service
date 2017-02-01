require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  let(:fullpath) { '/abc/def/ghi' }
  let(:rootpath) { '/' }

  let(:fullpath_link) { %(<li><a href="#{fullpath}">abc</a></li>) }
  let(:fullpath_active_link) do
    %(<li class="active"><a href="#{fullpath}">abc <span class="sr-only">(current)</span></a></li>)
  end

  let(:controller_inactive) do
    '<li class="dropdown"><a href="#" class="dropdown-toggle" '\
    'data-toggle="dropdown" role="button" aria-haspopup="true" '\
    'aria-expanded="false">Dashboards <span class="caret"></span></a>'\
    '<ul class="dropdown-menu"><li><a href="/dashboards">'\
    'List</a></li></ul></li>'
  end
  let(:controller_active) do
    '<li class="dropdown active"><a href="#" class="dropdown-toggle" '\
    'data-toggle="dropdown" role="button" aria-haspopup="true" '\
    'aria-expanded="false">Dashboards <span class="caret"></span></a>'\
    '<ul class="dropdown-menu"><li><a href="/dashboards">'\
    'List</a></li></ul></li>'
  end

  describe 'get_path' do
    it 'extracts the path from a full path' do
      expect(helper.get_path(rootpath)).to eq(rootpath)
      expect(helper.get_path(rootpath + '?a=b&c=d')).to eq(rootpath)
      expect(helper.get_path(fullpath)).to eq(fullpath)
      expect(helper.get_path(fullpath + '?a=b&c=d')).to eq(fullpath)
    end

    it 'returns nil if the path is empty' do
      expect(helper.get_path).to be_nil
    end
  end

  describe 'active_path?' do
    it 'returns false if either path or current_path are empty' do
      expect(helper.active_path?(nil, fullpath)).to be_falsy
      expect(helper.active_path?(fullpath, nil)).to be_falsy
    end

    it 'returns true if path is nil and current_path is empty' do
      expect(helper.active_path?(nil, '')).to be_truthy
    end
  end

  describe 'draw_link' do
    it 'returns a regular nav-bar link if the current_path is empty' do
      expect(helper.draw_link(fullpath, 'abc')).to eq(fullpath_link)
    end

    it "returns a regular nav-bar link if the current_path doesn't match the path" do
      expect(helper.draw_link(fullpath, 'abc', rootpath)).to eq(fullpath_link)
    end

    it 'returns an active nav-bar link if the current_path matches the path' do
      expect(helper.draw_link(fullpath, 'abc', fullpath)).to eq(fullpath_active_link)
    end
  end

  describe 'draw_controller' do
    it "returns a regular dropdown if the controller_name doesn't match the controller" do
      allow(controller).to receive(:controller_name).and_return('foo')

      expect(helper.draw_controller('dashboards', :index)).to eq(controller_inactive)
    end

    it 'returns an active dropdown if the controller_name match the controller' do
      allow(controller).to receive(:controller_name).and_return('dashboards')

      expect(helper.draw_controller('dashboards', :index)).to eq(controller_active)
    end
  end

  describe 'pretty_controller_name' do
    it 'returns a controller name as a singular title' do
      expect(helper.pretty_controller_name('csv_types')).to eq('Csv Type')
    end

    it 'returns a blank if the name is blank or ' do
      expect(helper.pretty_controller_name).to be_blank
    end
  end

  describe 'to_a_tag' do
    it 'returns an a tag' do
      expect(helper.to_a_tag('label', 'someplace')).to eq(%(<a href="someplace">label</a>))
    end

    it 'returns an a tag with var/value pairs' do
      var_vals = { 'var1' => 'val1', 'var2' => 'val2' }
      tag = %(<a href="someplace?var1=val1&var2=val2">label</a>)

      expect(helper.to_a_tag('label', 'someplace', var_vals)).to eq(tag)
    end

    it 'returns an a tag with the label set to the url if the label is blank' do
      expect(helper.to_a_tag(nil, 'someplace')).to eq(%(<a href="someplace">someplace</a>))
    end

    it 'returns an empty href a tag if url is blank' do
      expect(helper.to_a_tag('label', nil)).to eq(%(<a href="">label</a>))
    end

    it 'returns an empty a tag if label and url are blank' do
      expect(helper.to_a_tag(nil, nil)).to eq(%(<a href=""></a>))
    end
  end

  describe 'to_uri' do
    it 'returns a uri' do
      expect(helper.to_uri('someplace')).to eq('someplace')
    end

    it 'returns a uri with var/value pairs' do
      var_vals = { 'var1' => 'val1', 'var2' => 'val2' }
      uri = 'someplace?var1=val1&var2=val2'

      expect(helper.to_uri('someplace', var_vals)).to eq(uri)
    end

    it 'returns an empty uri if the url is blank' do
      expect(helper.to_uri(nil, 'a' => 'a')).to be_blank
    end
  end
end
