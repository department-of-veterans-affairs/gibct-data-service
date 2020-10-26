# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Upload, type: :model do
  subject(:upload) { build :upload, user: user }

  let(:user) { create :user }

  describe 'when validating' do
    it 'has a valid factory' do
      expect(upload).to be_valid
    end

    it 'requires the requesting user' do
      expect(build(:upload, user: nil)).not_to be_valid
    end

    it 'requires an upload_file to produce a filename' do
      expect(build(:upload, no_upload: true)).not_to be_valid
    end

    it 'requires a csv_type' do
      expect(build(:upload, csv_type: nil)).not_to be_valid
    end

    it 'defaults to !ok' do
      expect(build(:upload, csv_type: nil).ok).to be_falsey
    end

    describe 'and deriving columns' do
      it 'initializes csv column when not persisted' do
        expect(upload.csv).not_to be_blank
      end

      it 'does not initalize csv column if persisted' do
        upload.save
        expect(described_class.first.csv).not_to be_blank
      end
    end
  end

  describe 'ok?' do
    it 'returns the value of the ok column' do
      expect(upload.ok?).to eq(upload.ok)
      upload.ok = !upload.ok
      expect(upload.ok?).to eq(upload.ok)
    end
  end

  describe 'last_uploads' do
    before do
      # 3 Weam upload records
      create_list :upload, 3
      described_class.all[1].update(ok: true)

      create_list :upload, 3, csv_name: 'crosswalk.csv', csv_type: 'Crosswalk'
      described_class.where(csv_type: 'Crosswalk')[1].update(ok: true)
    end

    it 'gets the latest upload for each csv_type' do
      expect(described_class.last_uploads.length).to eq(2)
    end

    it 'gets only the latest upload for each csv_type' do
      max_weam = described_class.find_by(csv_type: 'Weam', ok: true)
      max_crosswalk = described_class.find_by(csv_type: 'Crosswalk', ok: true)
      uploads = described_class.last_uploads

      expect(uploads.where(csv_type: 'Weam').first).to eq(max_weam)
      expect(uploads.where(csv_type: 'Crosswalk').first).to eq(max_crosswalk)
    end
  end

  describe 'latest_uploads' do
    before do
      # 3 Weam upload records
      create_list :upload, 3
      described_class.all[1].update(ok: true)

      create_list :upload, 3, csv_name: 'crosswalk.csv', csv_type: 'Crosswalk'
      described_class.where(csv_type: 'Crosswalk')[1].update(ok: true)
    end

    it 'returns all uploads if preview is blank' do
      expect(described_class.since_last_preview_version.any?).to eq(true)
    end

    it 'returns uploads after preview' do
      create :version, :preview
      described_class.where(csv_type: 'Weam')[1].update(ok: true)
      create :version, :production, number: Version.current_preview.number
      create :version, :preview
      described_class.where(csv_type: 'Crosswalk')[1].update(ok: true)
      expect(described_class.since_last_preview_version.map(&:csv_type)).to include('Crosswalk')
      expect(described_class.since_last_preview_version.map(&:csv_type)).not_to include('Weam')
    end
  end

  describe 'from_csv_type' do
    it 'returns upload object with of CSV type' do
      upload = described_class.from_csv_type(Weam.name)
      expect(upload.csv_type).to eq(Weam.name)
      expect(upload.skip_lines).to eq(0)
    end
  end
end
