# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProcessUploadJob, type: :job do
  describe '#perform' do
    let(:job) { described_class.new }
    let(:user) { create :user }
    let(:upload) { create(:async_upload, :with_blob, user: user, status_message: status)}
    let(:klass) { upload.csv_type.constantize }
    let(:status) { 'queued for upload' }
    let(:upload_processor) { instance_double("UploadFileProcessor") }

    context 'with successful database import' do
      it 'calls UploadFileProcessor#load_file' do
        allow(UploadFileProcessor).to receive(:new).with(upload).and_return(upload_processor)
        expect(upload_processor).to receive(:load_file)
        job.perform(upload)
      end

      it 'saves alerts as json to upload#status_message' do
        expect { job.perform(upload) }.to change { upload.status_message }.from(status)
        .to("{\"csv_success\":{\"total_rows_count\":\"#{row_count}\",\"valid_rows\":\"#{row_count}\",\"failed_rows_count\":\"0\"},\"warning\":{}}")
      end
    end

    context 'with failed database import' do
      it 'cancels upload' do
        allow(UploadFileProcessor).to receive(:new).with(upload).and_return(upload_processor)
        allow(upload_processor).to receive(:load_file).and_raise(StandardError)
        expect(upload).to receive(:cancel!)
        job.perform(upload)
      end
    end
  end

  def row_count
    upload.blob.scan(/\n/).count - 1
  end
end
