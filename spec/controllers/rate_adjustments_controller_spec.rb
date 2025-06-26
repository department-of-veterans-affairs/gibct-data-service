# frozen_string_literal: true

require 'rails_helper'
require 'support/controller_macros'
require 'support/devise'
require 'controllers/shared_examples/shared_examples_for_authentication'

RSpec.describe RateAdjustmentsController, type: :controller do
  describe 'POST #update' do
    login_user

    let(:rate_adjustment) { create(:rate_adjustment) }
    let(:new_rate) { rate_adjustment.rate + 1.0 }
    let(:params) do
      {
        rate_adjustments: {
          rate_adjustment.id.to_s => { rate: new_rate }
        }
      }
    end

    it 'updates rate adjustments' do
      request.headers['ACCEPT'] = 'text/vnd.turbo-stream.html'
      post(:update, params: params)
      expect(rate_adjustment.reload.rate).to eq(new_rate)
    end
  end
end
