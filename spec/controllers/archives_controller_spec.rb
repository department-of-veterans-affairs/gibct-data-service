# frozen_string_literal: true

require 'rails_helper'
require 'support/controller_macros'
require 'support/devise'
require 'controllers/shared_examples/shared_examples_for_authentication'

RSpec.describe ArchivesController, type: :controller do
  it_behaves_like 'an authenticating controller', :index, 'archives'

  describe 'GET #index' do
    login_user

    before do
      create_list :version, :production, 3

      get(:index)
    end

    it 'populates an array of uploads' do
      expect(assigns(:uploads).length).to eq(CSV_TYPES_ALL_TABLES.length)
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET export' do
    login_user

    before do
      defaults = YAML.load_file(Rails.root.join('config', 'csv_file_defaults.yml'))

      CSV_TYPES_ALL_TABLES.each do |klass|
        load_table(klass, skip_lines: defaults[klass.name]['skip_lines'],
                          force_simple_split: defaults[klass.name]['force_simple_split'],
                          strip_chars_from_headers: defaults[klass.name]['strip_chars_from_headers'])
      end

      post(:build)
    end

    it 'causes a CSV to be exported' do
      allow(Weam).to receive(:export)
      get(:export, params: { csv_type: 'Weam', format: :csv })
      expect(Weam).to have_received(:export)
    end

    it 'includes filename parameter in content-disposition header' do
      get(:export, params: { csv_type: 'Sva', format: :csv })
      expect(response.headers['Content-Disposition']).to include('filename="Sva.csv"')
    end

    it 'redirects to index on error' do
      expect(get(:export, params: { csv_type: 'BlahBlah', format: :csv })).to redirect_to(action: :index)
      expect(get(:export, params: { csv_type: 'Weam', format: :xml })).to redirect_to(action: :index)
    end
  end
end
