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

    before { request.headers['ACCEPT'] = 'text/vnd.turbo-stream.html' }

    it_behaves_like 'a collection updatable', :rate

    it 'reassigns values for rate adjustments and calculator constants' do
      post(:update, params:)
      expect(assigns(:rate_adjustments)).to eq(RateAdjustment.by_chapter_number)
      expect(assigns(:calculator_constants)).to eq(CalculatorConstant.all)
    end

    it 'deletes records marked for destroy' do
      post(:update, params:)
      expect(RateAdjustment.all).not_to include(rate_adjustments.first)
    end

    it 'creates records in marked for create' do
      post(:update, params:)
      expect(RateAdjustment.last.benefit_type).to eq(new_rate['benefit_type'])
      expect(RateAdjustment.last.rate).to eq(new_rate['rate'])
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
