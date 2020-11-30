# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Group, type: :model do
  subject(:group) { build :group, user: user }

  let(:user) { create :user }

  describe 'initialize' do
    it 'has a valid factory' do
      expect(group).to be_valid
    end

    it 'has group_config' do
      expect(group.group_config).to be_present
    end
  end

  describe 'sheet_names' do
    it 'has classes names from config/group_types' do
      sheet_names = described_class.group_config_options(group.csv_type)[:types]&.map(&:name)
      expect(group.sheet_names).to eq(sheet_names)
    end
  end

  describe 'sheets' do
    it 'has classes from config/group_types' do
      sheets = described_class.group_config_options(group.csv_type)[:types]
      expect(group.sheets).to eq(sheets)
    end
  end

  describe 'group_config_options' do
    it 'returns group type config' do
      group_type = 'Accreditation'
      expect(described_class.group_config_options(group_type)[:klass]).to eq(group_type)
    end
  end

  describe 'export_as_zip' do
    it 'returns binary_data' do
      binary_data = described_class.export_as_zip('Accreditation')
      expect(binary_data).to be_present
    end
  end
end
