# frozen_string_literal: true

require 'rails_helper'
require 'support/controller_macros'
require 'support/devise'
require 'controllers/shared_examples/shared_examples_for_collection_updatable'

RSpec.describe RateAdjustmentsController, type: :controller do
  describe 'POST #update' do
    login_user

    let(:rate_adjustments) { create_list(:rate_adjustment, 2) }
    let(:new_rate) { build(:rate_adjustment).attributes.merge('id' => 'new_rate_1234') }
    let(:update_params) do
      adjustments = rate_adjustments.concat([new_rate])
      adjustments.each_with_object({}) do |adjustment, hash|
        hash[adjustment['id']] = { 'rate' => adjustment['rate'] }
      end
    end
    let(:params) do
      { rate_adjustments: update_params,
        marked_for_destroy: [rate_adjustments.first.id],
        marked_for_create: [new_rate.slice('id', 'benefit_type')] }
    end
    let(:created_rate) { create(:rate_adjustment) }

    before do
      request.headers['ACCEPT'] = 'text/vnd.turbo-stream.html'
      allow(RateAdjustment).to receive(:create).and_return(created_rate)
    end

    it_behaves_like 'a collection updatable', :rate

    it 'assigns values for updated/created/destroyed rate adjustments and calculator constants' do
      post(:update, params:)
      expect(assigns(:rate_adjustments)).to eq(RateAdjustment.by_chapter_number)
      expect(assigns(:calculator_constants)).to eq(CalculatorConstant.all)
      expect(assigns(:destroyed)).to eq([rate_adjustments.first])
      expect(assigns(:created)).to eq([created_rate])
    end
  end

  describe 'POST #build' do
    login_user

    let(:params) { { 'benefit_type' => '99' } }

    it 'generates new unpersisted rate adjustment with rate of 0.0' do
      expect { post(:build, params:, format: :turbo_stream) }.to change(RateAdjustment, :count).by(0)
      expect(assigns(:rate_adjustment).benefit_type).to eq(99)
      expect(assigns(:rate_adjustment).rate).to eq(0.0)
    end
  end
end
