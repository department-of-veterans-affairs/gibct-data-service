# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DashboardsHelper, type: :helper do
  let(:upload) { build :upload, :valid_upload }
  let(:missing_required) { build :upload, :missing_required }
  let(:missing_upload) { build :upload, :missing_upload }
  let(:user) { User.first }

  describe 'latest_upload_class' do
    it 'no class for ok upload' do
      expect(helper.latest_upload_class(upload)).to eq('')
    end

    it 'danger class for missing required upload' do
      expect(helper.latest_upload_class(missing_required)).to eq('danger')
    end

    it 'warning class for missing upload' do
      expect(helper.latest_upload_class(missing_upload)).to eq('warning')
    end
  end

  describe 'latest_upload_title' do
    it 'no class for ok upload' do
      expect(helper.latest_upload_title(upload)).to eq('')
    end

    it 'danger class for missing required upload' do
      expect(helper.latest_upload_title(missing_required)).to eq('Missing required upload')
    end

    it 'warning class for missing upload' do
      expect(helper.latest_upload_title(missing_upload)).to eq('Missing upload')
    end
  end

  describe 'cannot_fetch_api' do
    it 'returns false when fetch is not in progress' do
      create :upload, :scorecard_finished
      expect(helper.cannot_fetch_api(Scorecard.name)).to eq(false)
    end

    it 'returns true when fetch is in progress' do
      create :upload, :scorecard_in_progress
      expect(helper.cannot_fetch_api(Scorecard.name)).to eq(true)
    end
  end
end
