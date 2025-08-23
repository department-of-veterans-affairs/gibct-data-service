# frozen_string_literal: true

require 'rails_helper'
require 'support/controller_macros'
require 'support/devise'
require 'controllers/shared_examples/shared_examples_for_authentication'
require 'controllers/shared_examples/shared_examples_for_collection_updatable'

RSpec.describe CalculatorConstantsController, type: :controller do
  it_behaves_like 'an authenticating controller', :index, 'calculator_constants'

  describe 'GET #index' do
    login_user

    it 'returns calculator constants and rate adjustments' do
      create(:calculator_constant, :associated_rate_adjustment)
      get :index
      previous_year = 1.year.ago.year
      expect(assigns(:calculator_constants)).to eq(CalculatorConstant.all)
      expect(assigns(:constants_unpublished)).to eq(CalculatorConstant.unpublished?)
      expect(assigns(:previous_constants)).to eq(CalculatorConstantVersionsArchive.circa(previous_year))
      expect(assigns(:earliest_available_year)).to eq(CalculatorConstantVersionsArchive.earliest_available_year)
      expect(assigns(:rate_adjustments)).to eq(RateAdjustment.by_chapter_number)
    end
  end

  describe 'POST #update' do
    login_user

    it_behaves_like 'a collection updatable', :float_value

    it 'flashes updated fields' do
      constant = create(:calculator_constant, name: 'AVEREPAYMENTRATE')
      params = { calculator_constants: { constant.id.to_s => { float_value: constant.float_value + 1 } } }
      post(:update, params: params)
      expect(flash[:success][:updated_fields]).to include(constant.name)
    end

    # This is the mechanism that tells the generate version function something changed
    # that needs a new version to be generated
    it 'creates an upload row and sets the columns to expected values' do
      constant = create(:calculator_constant, name: 'AVEREPAYMENTRATE')
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

  describe 'GET #export' do
    login_user

    let(:current_year) { Time.zone.now.year }

    before do
      v2022 = create(:version, :production, :from_year, year: 2022)
      create_list(:calculator_constant_versions_archive, 5, year: 2022, version: v2022)

      v2023 = create(:version, :production, :from_year, year: 2023)
      create_list(:calculator_constant_versions_archive, 5, year: 2023, version: v2023)

      v2024 = create(:version, :production, :from_year, year: 2024)
      create_list(:calculator_constant_versions_archive, 5, year: 2024, version: v2024)

      live_version = create(:version, :production, :from_year, year: current_year)
      create_list(:calculator_constant_versions_archive, 5, version: live_version)
    end

    it 'receives start and end year params and exports a version history' do
      allow(CalculatorConstantVersionsArchive).to receive(:export_version_history).with(2022, current_year)
      get(:export, params: { start_year: 2022, end_year: current_year, format: :csv })
      expect(CalculatorConstantVersionsArchive).to have_received(:export_version_history)
    end

    it 'includes filename parameter in content-disposition header' do
      get(:export, params: { start_year: 2022, end_year: current_year, format: :csv })
      expect(response.headers['Content-Disposition']).to include("CalculatorConstants_2022_to_#{current_year}.csv")
    end
  end
end
