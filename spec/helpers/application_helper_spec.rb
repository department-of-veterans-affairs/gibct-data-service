# frozen_string_literal: true
require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe 'draw_controller_index_link' do
    let(:active) { %(<li class="active"><a href="/test_cts">Test ct<span class="sr-only">(current)</span></a></li>) }
    let(:inactive) { %(<li><a href="/not_test_cts">Not test ct</a></li>) }

    before(:each) do
      helper.define_singleton_method :controller_name do
        'test_cts'
      end

      helper.define_singleton_method :test_cts_path do
        '/' + controller_name
      end

      helper.define_singleton_method :not_test_cts_path do
        '/not_' + controller_name
      end
    end

    it 'creates an active nav link' do
      expect(helper.draw_controller_index_link('test_cts')).to eq(active)
    end

    it 'creates an inactive nav link' do
      expect(helper.draw_controller_index_link('not_test_cts')).to eq(inactive)
    end
  end
end
