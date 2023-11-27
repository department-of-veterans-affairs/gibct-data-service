# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccreditationTypeKeywordsController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/accreditation_type_keywords').to route_to('accreditation_type_keywords#index')
    end

    it 'routes to #new' do
      expect(get: '/accreditation_type_keywords/new').to route_to('accreditation_type_keywords#new')
    end

    it 'routes to #create' do
      expect(post: '/accreditation_type_keywords').to route_to('accreditation_type_keywords#create')
    end

    it 'routes to #destroy' do
      expect(delete: '/accreditation_type_keywords/1').to route_to('accreditation_type_keywords#destroy', id: '1')
    end
  end
end
