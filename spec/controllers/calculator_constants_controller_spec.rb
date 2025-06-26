# frozen_string_literal: true

require 'rails_helper'
require 'support/controller_macros'
require 'support/devise'
require 'controllers/shared_examples/shared_examples_for_authentication'

RSpec.describe CalculatorConstantsController, type: :controller do
  it_behaves_like 'an authenticating controller', :index, 'calculator_constants'

  describe 'GET #index' do
    login_user

    it 'returns calculator constants and rate adjustments' do
      create_list(:calculator_constant, 2, :associated_rate_adjustment)
      get :index
      expect(assigns(:calculator_constants)).to eq(CalculatorConstant.all)
      expect(assigns(:rate_adjustments)).to eq(RateAdjustment.by_chapter_number)
    end
  end

  describe 'POST #update' do
    login_user

    let(:calculator_constant) { create(:calculator_constant) }
    let(:new_value) { calculator_constant.float_value + 1.0 }
    let(:params) do
      {
        calculator_constants: {
          calculator_constant.id.to_s => { float_value: new_value }
        }
      }
    end

    it 'updates calculator constants and flashes updated fields' do
      post(:update, params: params)
      expect(calculator_constant.reload.float_value).to eq(new_value)
      expect(flash[:success][:updated_fields]).to include(calculator_constant.name)
    end
  end

  describe 'POST #apply_rate_adjustments' do
    login_user

    let(:calculator_constant) { create(:calculator_constant, :associated_rate_adjustment) }
    let(:rate_adjustment_id) { calculator_constant.rate_adjustment_id }
    let(:params) {{ rate_adjustment_id: rate_adjustment_id }}

    it 'updates calculator constants associated with rate adjustment and flashes updated fields' do
      allow(CalculatorConstant).to receive(:by_rate_adjustment)
        .with(rate_adjustment_id.to_s)
        .and_return([calculator_constant])
      allow(calculator_constant).to receive(:apply_rate_adjustment).and_call_original
      post(:apply_rate_adjustments, params: params)
      expect(calculator_constant).to have_received(:apply_rate_adjustment)
      expect(flash[:success][:updated_fields]).to include(calculator_constant.name)
    end
  end
end
