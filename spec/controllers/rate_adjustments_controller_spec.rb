# frozen_string_literal: true

require 'rails_helper'
require 'support/controller_macros'
require 'support/devise'
require 'controllers/shared_examples/shared_examples_for_authentication'
require 'controllers/shared_examples/shared_examples_for_collection_updatable'

RSpec.describe RateAdjustmentsController, type: :controller do
  describe 'POST #update' do
    login_user

    before { request.headers['ACCEPT'] = 'text/vnd.turbo-stream.html' }

    it_behaves_like 'a collection updatable', :rate
  end
end
