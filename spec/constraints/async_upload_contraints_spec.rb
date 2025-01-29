# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AsyncUploadConstraint do
  let(:non_async_constraint) { described_class.new(async_enabled: false) }
  let(:async_constraint) { described_class.new(async_enabled: true) }
  let(:csv_type) { 'Program' }
  let(:upload_file) { build(:upload).upload_file }
  let(:request) { double(params: upload_params) }

  before do
    settings = Common::Shared.file_type_defaults(csv_type)
    settings.merge!(async_upload: { enabled: async_enabled })
    allow(Common::Shared).to receive(:file_type_defaults).and_return(settings)
  end

  shared_examples 'upload request' do
    context 'when async not enabled for file type' do
      let(:async_enabled) { false }

      it "matches non async requests" do
        expect(non_async_constraint.matches?(request)).to be !async_enabled
      end
  
      it "matches async requests" do
        expect(async_constraint.matches?(request)).to be async_enabled
      end
    end

    context 'when async enabled for file type' do
      let(:async_enabled) { true }

      it "matches non async requests" do
        expect(non_async_constraint.matches?(request)).to be !async_enabled
      end
  
      it "matches async requests" do
        expect(async_constraint.matches?(request)).to be async_enabled
      end
    end
  end

  describe 'matches request by csv type' do
    let(:upload_params) do
      {
        upload: { upload_file: upload_file,
                  skip_lines: 0,
                  comment: 'Test',
                  csv_type: }
      }
    end

    it_behaves_like 'upload request'
  end

  describe 'matches request by upload id' do
    let(:user) { create(:user) }
    let(:upload) { create(:upload, user: user) }
    let(:upload_params) {{ id: upload.id }}

    it_behaves_like 'upload request'
  end
end
