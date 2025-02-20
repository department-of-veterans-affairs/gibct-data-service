# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UploadFileProcessor do
  let(:user) { create :user }
  let(:service) { described_class.new(upload) }
  let(:upload) { create(:upload, user: user) }

  describe '#load_file' do
    let(:klass) { upload.csv_type.constantize }
    let(:klass_double) { class_double(klass, :load_with_roo => [{ results: 'sample data' }]) }
    let(:file_options) do
      { liberal_parsing: upload.liberal_parsing,
        sheets: [{ klass:,
                   skip_lines: upload.skip_lines.try(:to_i),
                   clean_rows: upload.clean_rows,
                   multiple_files: upload.multiple_file_upload }] }
    end

    context 'when async disabled' do
      before { allow(upload).to receive(:async_enabled?).and_return(false) }

      it 'loads rows from reassembled body into database' do
        expect { service.load_file }.to change(klass, :count).by(row_count)
      end

      it 'calls klass#load_with_roo with non-async file options' do
        allow(service).to receive(:klass).and_return(klass, klass, klass_double, klass)
        service.load_file
        expect(klass_double).to have_received(:load_with_roo).with(upload.upload_file.tempfile, file_options)
      end

      it 'returns hash of import results' do
        expect(service.load_file).to include(:results, :header_warnings, :klass)
      end
    end

    context 'when async enabled' do
      let(:upload) { create(:async_upload, :with_body, user: user) }
      let(:async_options) do
        { async: { enabled: true,
                   upload_id: upload.id } }
      end
      let(:async_file_options) { file_options.merge(async_options) }

      before { allow(upload).to receive(:async_enabled?).and_return(true) }

      it 'loads rows from reassembled body into database' do
        expect { service.load_file }.to change(klass, :count).by(row_count)
      end

      it 'calls klass#load_with_roo with async file options' do
        allow(Tempfile).to receive(:new).and_return(upload.upload_file.tempfile)
        allow(service).to receive(:klass).and_return(klass, klass, klass, klass_double, klass)
        service.load_file
        expect(klass_double).to have_received(:load_with_roo).with(upload.upload_file.tempfile, async_file_options)
      end

      it 'returns hash of import results' do
        expect(service.load_file).to include(:results, :header_warnings, :klass)
      end
    end
  end

  describe 'self.parse_results' do
    let(:data) { service.load_file }

    it 'parses results from data import and returns hash' do
      parsed = described_class.parse_results(data)
      expect(parsed).to include(:total_rows_count, :failed_rows_count, :validation_warnings,
                                :header_warnings, :valid_rows)
      expect(parsed[:total_rows_count]).to eq(row_count)
      expect(parsed[:valid_rows]).to eq(row_count)
    end
  end

  def row_count
    file_content.scan(/\n/).count - 1
  end

  def file_content
    content = upload.upload_file.read
    upload.upload_file.rewind
    content
  end
end
