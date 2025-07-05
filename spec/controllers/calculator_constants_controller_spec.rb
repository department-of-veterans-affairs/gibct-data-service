# frozen_string_literal: true

require 'rails_helper'
require 'support/controller_macros'
require 'support/devise'
require 'controllers/shared_examples/shared_examples_for_authentication'
require 'controllers/shared_examples/shared_examples_for_collection_updatable'

RSpec.describe CalculatorConstantsController, type: :controller do
  before { CalculatorConstant.delete_all }
  
  it_behaves_like 'an authenticating controller', :index, 'calculator_constants'

  describe 'GET #index' do
    login_user

    it 'returns calculator constants and rate adjustments' do
      create_list(:calculator_constant, 2, :associated_rate_adjustment)
      get :index
      previous_year = 1.year.ago.year
      expect(assigns(:calculator_constants)).to eq(CalculatorConstant.all)
      expect(assigns(:constants_unpublished)).to eq(CalculatorConstant.unpublished?)
      expect(assigns(:previous_constants)).to eq(CalculatorConstantVersionsArchive.circa(previous_year))
      expect(assigns(:rate_adjustments)).to eq(RateAdjustment.by_chapter_number)
    end
  end

  describe 'POST #update' do
    login_user

    it_behaves_like 'a collection updatable', :float_value

    it 'flashes updated fields' do
      constant = create(:calculator_constant)
      params = { calculator_constants: { constant.id.to_s => { float_value: constant.float_value + 1 } } }
      post(:update, params: params)
      expect(flash[:success][:updated_fields]).to include(constant.name)
    end

    # This is the mechanism that tells the generate version function something changed
    # that needs a new version to be generated
    it 'creates an upload row and sets the columns to expected values' do
      constant = create(:calculator_constant)
      params = { calculator_constants: { constant.id.to_s => { float_value: constant.float_value + 1 } } }
      post(:update, params: params)
      expect(Upload.count).to eq(1)

      uploade = Upload.last
      expect(uploade.user).to eq current_user
      expect(uploade.csv).to eq 'Gonculator Constants Online'
      expect(uploade.csv_type).to eq 'CalculatorConstant'
      expect(uploade.comment).to eq 'Updated Gonculator Constant value(s)'
      expect(uploade.ok).to eq true
      expect(uploade.completed_at).not_to be nil
      expect(uploade.multiple_file_upload).to eq false
    end
  end

  describe 'POST #apply_rate_adjustments' do
    login_user

    let(:calculator_constant) { create(:calculator_constant, :associated_rate_adjustment) }
    let(:rate_adjustment_id) { calculator_constant.rate_adjustment_id }
    let(:params) { { rate_adjustment_id: rate_adjustment_id } }

    it 'updates calculator constants associated with rate adjustment and flashes updated fields' do
      allow(CalculatorConstant).to receive(:where)
        .with({ rate_adjustment_id: rate_adjustment_id.to_s })
        .and_return([calculator_constant])
      allow(calculator_constant).to receive(:apply_rate_adjustment).and_call_original
      post(:apply_rate_adjustments, params: params)
      expect(calculator_constant).to have_received(:apply_rate_adjustment)
      expect(flash[:success][:updated_fields]).to include(calculator_constant.name)
    end

    # This is the mechanism that tells the generate version function something changed
    # that needs a new version to be generated
    it 'creates an upload row and sets the columns to expected values' do
      create(:calculator_constant)
      post(:apply_rate_adjustments, params: params)
      expect(Upload.count).to eq(1)

      uploade = Upload.last
      expect(uploade.user).to eq current_user
      expect(uploade.csv).to eq 'Gonculator Constants Online'
      expect(uploade.csv_type).to eq 'CalculatorConstant'
      expect(uploade.comment).to eq 'Updated Gonculator Constant value(s)'
      expect(uploade.ok).to eq true
      expect(uploade.completed_at).not_to be nil
      expect(uploade.multiple_file_upload).to eq false
    end
  end
end
