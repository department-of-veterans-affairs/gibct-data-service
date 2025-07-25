# frozen_string_literal: true

require 'rails_helper'

RSpec.describe VersionPublicExport, type: :model do
  let(:version) { create :version, :production }

  before do
    create_list :institution, 3, version_id: version.id
  end

  describe '::build' do
    context 'with no existing public export model' do
      it 'creates a new one' do
        expect { described_class.build(version.id) }.to change(described_class, :count).by(1)
        model = described_class.find_by(version_id: version.id)
        expect(model.file_type).to eq('application/x-gzip')
        expect(model.data).not_to be_blank
      end
    end

    context 'with an existing public export model' do
      let!(:existing) { described_class.create!(version: version) }

      it 'updates the existing one' do
        expect(existing.file_type).to be_blank
        expect(existing.data).to be_blank

        expect { described_class.build(version.id) }.not_to change(described_class, :count)

        existing.reload
        expect(existing.file_type).not_to be_blank
        expect(existing.data).not_to be_blank
      end
    end
  end
end
