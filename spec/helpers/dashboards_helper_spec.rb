# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DashboardsHelper, type: :helper do
  let(:upload) { build :upload, :valid_upload }
  let(:missing_required) { build :upload, :missing_required }
  let(:missing_upload) { build :upload, :missing_upload }
  let(:user) { User.first }
  let(:preview_version1) { FactoryBot.create(:version, :preview) }
  let(:preview_version2) { FactoryBot.create(:version, :preview) }
  let(:prod_version1) { FactoryBot.create(:version, :production) }
  let(:prod_version2) { FactoryBot.create(:version, :production) }

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

  describe 'can_generate_preview' do
    it 'returns disabled when fetch is not in progress' do
      create :upload, :scorecard_finished
      expect(helper.can_generate_preview([preview_version1, preview_version2])).to eq('disabled')
    end

    it 'does not return disabled when fetch is in progress' do
      create :upload, :scorecard_in_progress
      expect(helper.can_generate_preview([prod_version1, prod_version2])).to eq(nil)
    end

    it 'returns disabled when publishing is in progress' do
      create :version, :production
      create :preview_generation_status_information, :publishing

      expect(helper.can_generate_preview([])).to eq('disabled')
    end
  end

  describe 'preview_generation_started?' do
    it 'returns true when rows exist on the preview generation status table' do
      create :preview_generation_status_information
      expect(helper.preview_generation_started?).to eq(true)
    end

    it 'returns false when no rows exist on the preview generation status table' do
      PreviewGenerationStatusInformation.delete_all
      expect(helper.preview_generation_started?).to eq(false)
    end
  end

  describe 'preview_generation_completed?' do
    it 'is falsey if the preview generation has not started' do
      PreviewGenerationStatusInformation.delete_all
      expect(helper.preview_generation_completed?).to be_nil
    end

    it 'returns false if the preview generation has started but not completed' do
      create :preview_generation_status_information
      expect(helper.preview_generation_completed?).to eq(false)
    end

    it 'returns true if the preview generation has started and completed' do
      create(:preview_generation_status_information, :complete)
      expect(helper.preview_generation_completed?).to eq(true)
    end

    it 'returns true if the preview generation has started and completed with an error' do
      create(:preview_generation_status_information, :complete_error)
      expect(helper.preview_generation_completed?).to eq(true)
    end
  end

  describe 'locked_fetches_exist?' do
    it 'returns true if there are failed fetches' do
      create(:upload, :failed_upload)
      expect(helper.locked_fetches_exist?).to eq(true)
    end

    it 'returns false if there are failed fetches' do
      create(:upload, :valid_upload)
      expect(helper.locked_fetches_exist?).to eq(false)
    end
  end

  describe 'disable_upload?' do
    it 'returns true if the upload is disabled' do
      create(:upload, :disabled_upload)
      upload = Upload.first
      expect(helper.disable_upload?(upload)).to eq(true)
    end

    it 'returns false if the upload is not disabled' do
      create(:upload)
      upload = Upload.first
      expect(helper.disable_upload?(upload)).to eq(false)
    end
  end

  describe 'current_user_can_upload?' do
    before do
      User.create(email: 'John.Doe@va.gov', password: Faker::Internet.password.to_s)
    end

    describe 'in non production mode' do
      it 'returns true if the current environment is not production' do
        allow(helper).to receive(:current_user).and_return(User.first)
        expect(helper.current_user_can_upload?).to eq(true)
      end
    end

    describe 'in production mode' do
      it 'returns false if the current environment is production' do
        allow(ENV).to receive(:fetch).with('RAILS_ENV').and_return('production')

        expect(helper.current_user_can_upload?).to eq(false)
      end

      it 'returns false if the deployment environment is staging and it is not noah or gregg' do
        allow(ENV).to receive(:fetch).with('RAILS_ENV').and_return('production')
        allow(Settings).to receive(:environment).and_return('vagov-staging')
        allow(helper).to receive(:current_user).and_return(User.first)

        expect(helper.current_user_can_upload?).to eq(false)
      end

      it 'returns true if the deployment environment is staging and it is noah or gregg' do
        allow(ENV).to receive(:fetch).with('RAILS_ENV').and_return('production')
        allow(Settings).to receive(:environment).and_return('vagov-staging')

        %w[noah gregg nfstern gpuhala].each do |user_email|
          User.create(email: "#{user_email}@va.gov", password: Faker::Internet.password.to_s)
          allow(helper).to receive(:current_user).and_return(User.last)
          expect(helper.current_user_can_upload?).to eq(true)
        end
      end
    end
  end
end
