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

  describe '#lcpe_normalizable?' do
    subject(:upload) { build :upload, user: user, csv_type: }

    context 'when csv_type namespaced under Lcpe::Feed' do
      let(:csv_type) { Lcpe::Feed::Lac.name }

      it 'returns true' do
        expect(upload.lcpe_normalizable?).to be true
      end
    end

    context 'when csv_type namespaced under Lcpe but not normalizable' do
      let(:csv_type) { Lcpe::Lac.name }

      it 'returns true' do
        expect(upload.lcpe_normalizable?).to be false
      end
    end

    context 'when csv_type not namespaced under Lcpe' do
      let(:csv_type) { Weam.name }

      it 'returns true' do
        expect(upload.lcpe_normalizable?).to be false
      end
    end
  end

  describe '#normalize_lcpe!' do
    context 'when upload fails' do
      subject(:upload) { build :upload, :failed_upload }

      let(:csv_klass) { Lcpe::Feed::Lac }

      it 'does not receive #normalize_lcpe! after save' do
        allow(csv_klass).to receive(:normalize)
        upload.save
        expect(csv_klass).not_to have_received(:normalize)
      end
    end

    context 'when upload ok but not normalizable' do
      subject(:upload) { build :upload, :valid_upload, user: user, csv_type: csv_klass.name }

      let(:csv_klass) { Weam }

      it 'does not receive #normalize_lcpe! after save' do
        allow(Lcpe::PreloadDataset).to receive(:build)
        upload.save
        expect(Lcpe::PreloadDataset).not_to have_received(:build)
      end
    end

    context 'when upload ok and normalizable' do
      subject(:upload) { build :upload, :valid_upload, user: user, csv_type: csv_klass.name }

      let(:csv_klass) { Lcpe::Feed::Lac }
      let(:sql_context) { instance_double('Lcpe::SqlContext::Sql') }
      let(:normalized_klass) { csv_klass.const_get(:NORMALIZED_KLASS) }

      it 'receives #normalize_lcpe!' do
        allow(csv_klass).to receive(:normalize)
        upload.save
        expect(csv_klass).to have_received(:normalize)
      end

      it 'generates and executes SQL context' do
        allow(csv_klass).to receive(:normalize).and_return(sql_context)
        allow(sql_context).to receive(:execute)
        upload.normalize_lcpe!
        expect(sql_context).to have_received(:execute)
      end

      it 'builds preload dataset' do
        allow(Lcpe::PreloadDataset).to receive(:build)
        upload.normalize_lcpe!
        expect(Lcpe::PreloadDataset).to have_received(:build).with(normalized_klass)
      end
    end
  end

  describe '#sequential?' do
    context 'when upload non-sequential' do
      before do
        settings = Common::Shared.file_type_defaults(upload.csv_type)
        settings.merge!(sequential_upload: { enabled: false })
        allow(Common::Shared).to receive(:file_type_defaults).and_return(settings)
      end

      it 'returns false' do
        expect(upload.sequential?).to be false
      end
    end

    context 'when upload sequential' do
      before do
        settings = Common::Shared.file_type_defaults(upload.csv_type)
        settings.merge!(sequential_upload: { enabled: true })
        allow(Common::Shared).to receive(:file_type_defaults).and_return(settings)
      end

      it 'returns true' do
        expect(upload.sequential?).to be true
      end
    end
  end

  describe '#chunk_size' do
    context 'when upload non-sequential' do
      let(:chunk_size) { 10_000_000 }

      before do
        settings = Common::Shared.file_type_defaults(upload.csv_type)
        settings.merge!(sequential_upload: { enabled: false, chunk_size: })
        allow(Common::Shared).to receive(:file_type_defaults).and_return(settings)
      end

      it 'returns chunk size' do
        expect(upload.chunk_size).to eq(chunk_size)
      end
    end

    context 'when upload sequential' do
      let(:chunk_size) { 10_000_000 }

      before do
        settings = Common::Shared.file_type_defaults(upload.csv_type)
        settings.merge!(sequential_upload: { enabled: true, chunk_size: })
        allow(Common::Shared).to receive(:file_type_defaults).and_return(settings)
      end

      it 'returns chunk size' do
        expect(upload.chunk_size).to eq(chunk_size)
      end
    end
  end
end
