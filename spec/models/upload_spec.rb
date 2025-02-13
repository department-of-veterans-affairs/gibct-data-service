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
      expect(described_class.since_last_version.any?).to eq(true)
    end

    it 'returns uploads since the last version was generated' do
      described_class.where(csv_type: 'Weam')[1].update(ok: true)
      create :version, :production
      described_class.where(csv_type: 'Crosswalk')[1].update(ok: true)
      expect(described_class.since_last_version.map(&:csv_type)).to include('Crosswalk')
      expect(described_class.since_last_version.map(&:csv_type)).not_to include('Weam')
    end
  end

  describe 'from_csv_type' do
    it 'returns upload object with of CSV type' do
      upload = described_class.from_csv_type(Weam.name)
      expect(upload.csv_type).to eq(Weam.name)
      expect(upload.skip_lines).to eq(0)
    end
  end

  describe 'failed fetches (which locks the fetch button)' do
    before do
      create(:upload, :failed_upload)
    end

    it 'returns true if there are locked fetches' do
      expect(described_class.locked_fetches_exist?).to eq(true)
    end

    it '#unlock_fetches removes locked fetches' do
      expect(described_class.locked_fetches_exist?).to eq(true)
      described_class.unlock_fetches
      expect(described_class.locked_fetches_exist?).to eq(false)
    end
  end

  context 'when async upload' do
    subject(:upload) { build :async_upload, :active, user: user }

    let(:chunk_size) { 10_000_000 }

    before do
      settings = Common::Shared.file_type_defaults(upload.csv_type)
      settings.merge!(async_upload: { enabled: true, chunk_size: chunk_size })
      allow(Common::Shared).to receive(:file_type_defaults).and_return(settings)
    end

    describe 'when validating' do
      it 'has a valid factory' do
        expect(upload).to be_valid
      end
    end

    describe '::async_queue' do
      it 'lists active async uploads' do
        expect(described_class.async_queue).to be_empty
        upload.save
        expect(described_class.async_queue.length).to eq(1)
      end
    end

    describe '#check_async_queue' do
      it 'prevents creation of more than one active upload of same csv type' do
        expect(upload.save).to be true
        expect { create(:async_upload, :active, user: user) }.to raise_error(StandardError)
        expect(create(:async_upload, :active, user: user, csv_type: 'Weam')).to be_truthy
      end
    end

    describe '#async_upload_settings, #async_enabled?, #chunk_size' do
      it 'returns async settings for csv type' do
        expect(upload.async_upload_settings.keys).to eq(%i[enabled chunk_size])
        expect(upload.async_enabled?).to be true
        expect(upload.chunk_size).to eq(chunk_size)
      end
    end

    describe '#create_or_concat_blob' do
      let!(:upload_content) { upload.upload_file.read }

      before { upload.upload_file.rewind }

      it 'creates blob if upload#blob nil' do
        upload.save
        expect { upload.create_or_concat_blob }.to change { upload.reload.blob }.from(nil).to(upload_content)
      end

      it 'concats blob if upload#blob exists' do
        upload = create(:async_upload, :with_blob, user: user)
        expect { upload.create_or_concat_blob }.to change { upload.reload.blob }.to(upload.blob + upload_content)
      end

      it 'closes and unlinks upload file' do
        allow(upload.upload_file.tempfile).to receive(:close)
        allow(upload.upload_file.tempfile).to receive(:unlink)
        upload.create_or_concat_blob
        expect(upload.upload_file.tempfile).to have_received(:close)
        expect(upload.upload_file.tempfile).to have_received(:unlink)
      end
    end

    describe '#active?, #inactive?' do
      it 'returns #active? true if upload queued, not completed, not canceled, and not dead' do
        expect(upload.active?).to be true
        expect(upload.inactive?).to be false
      end

      it 'returns #active? false if upload completed' do
        upload = build(:async_upload, :valid_upload, user: user)
        expect(upload.active?).to be false
        expect(upload.inactive?).to be true
      end

      it 'returns #active? false if upload canceled' do
        upload = build(:async_upload, :canceled, user: user)
        expect(upload.active?).to be false
        expect(upload.inactive?).to be true
      end

      it 'returns #active? false if upload dead' do
        upload = build(:async_upload, :dead, user: user)
        expect(upload.active?).to be false
        expect(upload.inactive?).to be true
      end
    end

    describe '#cancel!' do
      it 'returns false if inactive' do
        upload = build(:async_upload, :canceled, user: user)
        expect(upload.cancel!).to be false
      end

      it 'returns true if upload active' do
        upload = build(:async_upload, :active, user: user)
        expect(upload.cancel!).to be true
      end

      it 'sets canceled_at value' do
        upload = build(:async_upload, :with_blob, user: user)
        expect { upload.cancel! }.to change { upload.canceled_at }.from(nil)
      end

      it 'clears blob and status message' do
        upload = build(:async_upload, :with_blob, status_message: 'sample status', user: user)
        expect { upload.cancel! }.to change { upload.slice(:blob, :status_message).values }
          .from([upload.blob, upload.status_message]).to([nil, nil])
      end
    end

    describe '#rollback_if_inactive' do
      before { upload.save }

      it 'throws error if upload inactive' do
        upload = build(:async_upload, :canceled, user: user)
        expect { upload.rollback_if_inactive }.to raise_error(StandardError)
      end

      it 'proceeds without error if upload active' do
        expect { upload.rollback_if_inactive }.not_to raise_error(StandardError)
      end
    end

    describe '#safely_update_status!' do
      let(:status) { 'sample status' }

      before { upload.save }

      it 'updates status in separate thread if upload active' do
        new_thread = upload.safely_update_status!(status)
        new_thread.join
        expect(upload.status_message).to eq(status)
      end

      it 'throws error if upload inactive' do
        upload = build(:async_upload, :canceled, user: user)
        expect { upload.safely_update_status!(status) }.to raise_error(StandardError)
      end
    end

    describe '#update_import_progress!' do
      let(:completed) { 49 }
      let(:total) { 100 }

      before { upload.save }

      it 'updates upload status during import with percent complete' do
        percent_complete = (completed.to_f / total) * 100
        new_thread = upload.update_import_progress!(completed, total)
        new_thread.join
        expect(upload.status_message).to eq("importing records: #{percent_complete.round}% . . .")
      end

      it 'throws error if upload inactive' do
        upload = build(:async_upload, :canceled, user: user)
        expect { upload.update_import_progress!(completed, total) }.to raise_error(StandardError)
      end
    end

    describe '#alerts' do
      it 'returns hash with fields if upload#status_message parsable JSON' do
        json_alerts = { alert_key_1: 'alert 1', alert_key_2: 'alert 2' }.to_json
        upload.update(status_message: json_alerts)
        expect(upload.alerts.keys).to eq(%i[alert_key_1 alert_key_2])
      end

      it 'returns empty hash if upload#status_message empty' do
        expect(upload.alerts).to be_empty
      end

      it 'returns empty hash if upload#status_message not parsable JSON' do
        upload.update(status_message: 'string status')
        expect(upload.alerts).to be_empty
      end
    end
  end
end
